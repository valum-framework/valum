using FastCGI;
using Soup;

/**
 * FastCGI implementation of VSGI.
 */
namespace VSGI.FastCGI {
	/**
	 * FastCGI Request parsed from FastCGI.request struct.
	 */
	class Request : VSGI.Request {

		private new weak request _request;

		private string _method = VSGI.Request.GET;
		private URI _uri;
		private HashTable<string, string>? _query = null;
		private MessageHeaders _headers = new MessageHeaders (MessageHeadersType.REQUEST);

		public override URI uri { get { return this._uri; } }

		public override HashTable<string, string>? query {
			get {
				return this._query;
			}
		}

		public override string method {
			owned get { return this._method; }
		}

		public override MessageHeaders headers {
			get { return this._headers; }
		}

		public Request (request request) {
			this._request = request;

			var environment = this._request.environment;

			this._uri = new URI (environment["PATH_TRANSLATED"]);

			// nullables
			this._uri.set_host (environment["SERVER_NAME"]);
			this._uri.set_query (environment["QUERY_STRING"]);

			// HTTP authentication credentials
			this._uri.set_user (environment["REMOTE_USER"]);

			if (environment["PATH_INFO"] != null)
				this._uri.set_path ((string) environment["PATH_INFO"]);

			// some server provide this one for the path
			if (environment["REQUEST_URI"] != null)
				this._uri.set_path ((string) environment["REQUEST_URI"]);

			if (environment["SERVER_PORT"] != null)
				this._uri.set_port (int.parse (environment["SERVER_PORT"]));

			if (environment["REQUEST_METHOD"] != null)
				this._method = (string) environment["REQUEST_METHOD"];

			// parse the HTTP query
			if (environment["QUERY_STRING"] != null)
				this._query = Form.decode ((string) environment["QUERY_STRING"]);

			var headers = new StringBuilder();

			foreach (var variable in this._request.environment.get_all ()) {
				// headers are prefixed with HTTP_
				if (variable.has_prefix ("HTTP_")) {
					var parts = variable.split("=", 2);
					headers.append ("%s: %s\r\n".printf(parts[0].substring(5).replace("_", "-").casefold(), parts[1]));
				}
			}

			headers_parse (headers.str, (int) headers.len, this._headers);
		}

		public override ssize_t read (uint8[] buffer, Cancellable? cancellable = null) throws IOError {
			var read = this._request.in.read (buffer);

			if (read == GLib.FileStream.EOF)
				throw new IOError.FAILED ("code %u: could not read from stream".printf (this._request.in.get_error ()));

			return read;
		}

		public bool flush (Cancellable? cancellable = null) {
			return this._request.in.flush ();
		}

		public override bool close (Cancellable? cancellable = null) throws IOError {
			return this._request.in.is_closed;
		}
	}

	/**
	 * FastCGI Response
	 */
	class Response : VSGI.Response {

		private new weak request _request;

		/**
		 * Tells if the headers part of the HTTP message has been written to the
		 * output stream.
		 */
		private bool headers_written = false;

		private uint _status;

		private MessageHeaders _headers = new MessageHeaders (MessageHeadersType.RESPONSE);

		public override uint status {
			get { return this._status; }
			set { this._status = value; }
		}

		public override MessageHeaders headers { get { return this._headers; } }

		public Response (Request req, request request) {
			base (req);
			this._request = request;
		}

		private ssize_t write_headers () throws IOError {
			// headers cannot be rewritten
			if (this.headers_written)
				error ("headers have already been written");

			var headers = new StringBuilder ();

			// status
			headers.append ("Status: %u %s\r\n".printf (this.status, Status.get_phrase (this.status)));

			// headers
			this.headers.foreach ((k, v) => {
				headers.append ("%s: %s\r\n".printf(k, v));
			});

			// newline preceeding the body
			headers.append ("\r\n");

			// write headers in a single operation
			var written = this._request.out.puts (headers.str);

			if (written == GLib.FileStream.EOF)
				return written;

			// headers are written if the write operation is successful (rewritten otherwise)
			this.headers_written = true;

			return written;
		}

		public override ssize_t write (uint8[] buffer, Cancellable? cancellable = null) throws IOError {
			// lock so that two threads would not write headers at the same time.
			lock (this.headers_written) {
				if (!this.headers_written)
					this.write_headers ();
			}

			var written = this._request.out.put_str (buffer);

			if (written == GLib.FileStream.EOF)
				throw new IOError.FAILED ("code %u: could not write body to stream".printf (this._request.out.get_error ()));

			return written;
		}

		/**
		 * Headers are written on the first flush call.
		 */
		public override bool flush (Cancellable? cancellable = null) {
			return this._request.out.flush ();
		}

		public override bool close (Cancellable? cancellable = null) throws IOError {
			// lock so that two threads would not write headers at the same time.
			lock (this.headers_written) {
				if (!this.headers_written)
					this.write_headers ();
			}

			return this._request.out.is_closed;
		}
	}

	/**
	 * FastCGI Server using GLib.MainLoop.
	 *
	 * @since 0.1
	 */
	public class Server : VSGI.Server {

		private request _request;

		public Server (VSGI.Application application) {
			Object (application: application, flags: ApplicationFlags.HANDLES_COMMAND_LINE);

			this.add_main_option ("socket", 's', 0, OptionArg.STRING, "socket", null);

			this.startup.connect (() => {
				init ();
			});
		}

		/**
		 * Handle the command line and setup the request.
		 */
		public override int command_line (ApplicationCommandLine command_line) {
			var source   = new TimeoutSource (0);
			var mainloop = new MainLoop ();

			var options     = command_line.get_options_dict ();
			var socket_path = options.contains ("socket") ? options.lookup_value ("socket", VariantType.STRING).get_string () : "";

			message (socket_path);

			var socket   = open_socket (socket_path, 0);

			if (socket == -1)
				error ("");

			request.init (out this._request, socket);

			source.set_callback (() => {
				// accept a new request
				var status = this._request.accept ();

				if (status < 0) {
					warning ("could not accept a request (code %d)", status);
					mainloop.quit ();
					this._request.close ();
					return false;
				}

				foreach (var env in this._request.environment.get_all())
				message (env);

				var req = new Request (this._request);
				var res = new Response (req, this._request);

				try {
					this.application.handle (req, res);
				} catch (Error e) {
					this._request.err.puts (e.message);
					this._request.out.set_exit_status (e.code);
				}

				message ("%u %s %s".printf (res.status, req.method, req.uri.get_path ()));

				this._request.finish ();

				return true;
			});

			source.attach (mainloop.get_context ());

			mainloop.run ();

			return 0;
		}
	}
}
