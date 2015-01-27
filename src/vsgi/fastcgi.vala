using FastCGI;

/**
 * FastCGI implementation of VSGI.
 */
namespace VSGI {

	/**
	 * FastCGI Request parsed from FastCGI.request struct.
	 */
	class FastCGIRequest : Request {

		private weak FastCGI.request request;

		private Soup.URI _uri = new Soup.URI (null);
		private Soup.MessageHeaders _headers = new Soup.MessageHeaders (Soup.MessageHeadersType.REQUEST);

		public override Soup.URI uri { get { return this._uri; } }

		public override string method {
			owned get { return this.request.environment["REQUEST_METHOD"]; }
		}

		public override Soup.MessageHeaders headers {
			get { return this._headers; }
		}

		public FastCGIRequest(FastCGI.request request) {
			this.request = request;

			this._uri.set_path (this.request.environment["PATH_INFO"]);
			this._uri.set_query (this.request.environment["QUERY_STRING"]);

			var headers = new StringBuilder();

			foreach (var variable in this.request.environment.get_all ()) {
				// headers are prefixed with HTTP_
				if (variable.has_prefix ("HTTP_")) {
					var parts = variable.split("=", 2);
					headers.append ("%s: %s\r\n".printf(parts[0].substring(5).replace("_", "-").casefold(), parts[1]));
				}
			}

			Soup.headers_parse (headers.str, (int) headers.len, this._headers);
		}

		public override ssize_t read (uint8[] buffer, Cancellable? cancellable = null) throws IOError {
			return this.request.in.read (buffer);
		}

		public override bool close (Cancellable? cancellable = null) throws IOError {
			return this.request.in.flush () && this.request.in.is_closed;
		}
	}

	/**
	 * FastCGI Response
	 */
	class FastCGIResponse : Response {

		private weak FastCGI.request request;

		/**
		 * Tells if the headers part of the HTTP message has been written to the
		 * output stream.
		 */
		private bool headers_written = false;

		private uint _status;

		private Soup.MessageHeaders _headers = new Soup.MessageHeaders (Soup.MessageHeadersType.RESPONSE);

		public override uint status {
			get { return this._status; }
			set { this._status = value; }
		}

		public override string mime {
			get { return this.headers.get_content_type (null); }
			set { this.headers.set_content_type (value, null); }
		}

		public override Soup.MessageHeaders headers { get { return this._headers; } }

		public FastCGIResponse(FastCGI.request request) {
			this.request = request;
		}

		private ssize_t write_headers () throws IOError {
			ssize_t written = 0;

			if (this.headers_written)
				error ("HTTP headers have already been written");

			var written_status = this.request.out.printf ("Status: %u %s\r\n", this.status, Soup.Status.get_phrase (this.status));

			if (written_status == GLib.FileStream.EOF)
				throw new IOError.FAILED ("could not write status to stream");

			written += written_status;

			// write headers...
			this.headers.foreach ((k, v) => {
				var w = this.request.out.printf ("%s: %s\r\n", k, v);

				if (w == GLib.FileStream.EOF)
					throw new IOError.FAILED ("could not write header to stream");

				written += w;
			});

			var written_empty_line = this.request.out.puts ("\r\n");

			if (written_empty_line == GLib.FileStream.EOF)
				throw new IOError.FAILED ("could not write empty line to stream");

			written += written_empty_line;

			this.headers_written = true;

			return written;
		}

		/**
		 * Headers are written on the first call of write.
		 */
		public override ssize_t write (uint8[] buffer, Cancellable? cancellable = null) throws IOError {
			ssize_t written = 0;

			// lock so that two threads would not write headers at the same time.
			lock (this.headers_written) {
				if (!this.headers_written)
					written += this.write_headers ();
			}

			// write body byte per byte
			foreach (var byte in buffer) {
				var w = this.request.out.putc (byte);

				if (w == GLib.FileStream.EOF)
					throw new IOError.FAILED ("could not write body to stream");

				written += w;
			}

			return written;
		}

		public override bool close (Cancellable? cancellable = null) {
			// write headers for empty message
			lock (this.headers_written) {
				if (!this.headers_written) {
					this.write_headers ();
				}
			}

			this.request.out.set_exit_status (0);

			return this.request.out.flush () && this.request.out.is_closed;
		}
	}

	/**
	 * FastCGI Server using GLib.MainLoop.
	 */
	public class FastCGIServer : VSGI.Server {

		private FastCGI.request request;

		public FastCGIServer (VSGI.Application app) {
			base (app);

			FastCGI.init ();

			FastCGI.request.init (out this.request);
		}

		/**
		 * Create a FastCGI Server from a socket.
		 *
		 * @param path    socket path or port number (port are written like :8080)
		 * @param backlog listen queue depth
		 */
		public FastCGIServer.from_socket (VSGI.Application app, string path, int backlog) {
			base (app);

			FastCGI.init ();

			var socket = FastCGI.open_socket (path, 0);

			assert (socket != -1);

			FastCGI.request.init (out this.request, socket);
		}

		public override void listen () {
			var loop = new MainLoop ();
			var source = new TimeoutSource (0);

			source.set_callback (() => {
				// accept a new request
				var status = this.request.accept ();

				if (status < 0) {
					warning ("could not accept a request (code %d)", status);
					this.request.close ();
					loop.quit ();
					return false;
				}

				info ("new request with id %d accepted", request.request_id);

				var req = new VSGI.FastCGIRequest (this.request);
				var res = new VSGI.FastCGIResponse (this.request);

				this.application.handler (req, res);

				message ("%u %s %s".printf (res.status, req.method, req.uri.get_path ()));

				// free the request
				this.request.finish ();

				return true;
			});

			source.attach (loop.get_context ());

			loop.run ();
		}
	}
}
