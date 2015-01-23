using Gee;
using FastCGI;

/**
 * FastCGI implementation of VSGI.
 */
namespace VSGI {

	/**
	 * FastCGI Request parsed from FastCGI.request struct.
	 */
	public class FastCGIRequest : Request {

		private weak FastCGI.request request;

		private Soup.URI _uri;
		private HashMap<string, string> _environment = new HashMap<string, string> ();
		private HashMultiMap<string, string> _headers = new HashMultiMap<string, string> ();

		public override Map<string, string> environment { get { return this._environment; } }

		public override Soup.URI uri { get { return this._uri; } }

		public override string method {
			owned get {
				return this._environment["REQUEST_METHOD"];
			}
		}

		public override MultiMap<string, string> headers { get { return this._headers; } }

		public FastCGIRequest(FastCGI.request request) {
			this.request = request;

			// extract environment variables
			message ("extracting environment variables...");
			foreach (var variable in this.request.environment.get_all ())
			{
				message (variable);
				var parts = variable.split("=", 2);
				this._environment[parts[0]] = parts[1];

				if (parts[0].has_prefix("HTTP_")) {
					// this is a header
					this.headers[parts[0][5:-1].replace("_", "-")] = parts[1];
				}
			}

			this._uri = new Soup.URI(null);

			this._uri.set_path (this.environment["PATH_INFO"]);
			this._uri.set_query (this.environment["QUERY_STRING"]);
		}

		public override ssize_t read (uint8[] buffer, Cancellable? cancellable = null) {
			return this.request.in.read (buffer);
		}

		public override bool close (Cancellable? cancellable = null) {
			return this.request.in.flush () && this.request.in.is_closed;
		}
	}

	/**
	 * FastCGI Response
	 */
	public class FastCGIResponse : Response {

		private weak FastCGI.request request;

		/**
		 * Tells if the HEAD part of the HTTP message has been written to the
		 * output stream.
		 */
		private bool head_written = false;

		private uint _status;

		private HashMultiMap _headers = new HashMultiMap<string, string> ();

		public override uint status {
			get { return this._status; }
			set { this._status = value; } }

		public override string mime {
			get {
				return this.headers["Content-Type"].to_array()[0];
			}
			set {
				this.headers["Content-Type"] = value;
			}
		}

		public override MultiMap<string, string> headers { get { return this._headers; } }

		public FastCGIResponse(FastCGI.request request) {
			this.request = request;
		}

		private int write_headers () {
			if (this.head_written) {
				message ("headers has already been written");
				return 0;
			}

			var written = 0;

			written += this.request.out.printf("Status: %u %s\r\n", this.status, Soup.Status.get_phrase (this.status));

			// write headers...
			this.headers.map_iterator().foreach((k, v) => {
				written += this.request.out.printf("%s: %s\r\n", k, v);
				return true;
			});

			written += this.request.out.puts("\r\n");

			return written;
		}

		/**
		 * Headers are written on the first call of write.
		 */
		public override ssize_t write (uint8[] buffer, Cancellable? cancellable = null) {

			var written = 0;

			// write headers
			if (!this.head_written) {
				written += this.write_headers ();
				this.head_written = true;
			}

			// write body byte per byte
			foreach (var byte in buffer) {
				written += this.request.out.putc (byte);
			}

			return written;
		}

		public override bool close (Cancellable? cancellable = null) {

			// it's kind of too late..
			if (!this.head_written) {
				this.write_headers ();
				this.head_written = true;
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

			source.set_callback(() => {

				// accept a new request
				var status = this.request.accept ();

				if (status < 0) {
					warning ("could not accept a request (code %d)", status);
					this.request.close ();
					loop.quit ();
					return false;
				}

				message ("new request with id %d accepted", request.request_id);

				// handle the request using FastCGI handler
				var req = new VSGI.FastCGIRequest (this.request);
				var res = new VSGI.FastCGIResponse (this.request);

				this.application.handler (req, res);

				this.request.finish();

				return true;
			});

			source.attach (loop.get_context ());

			loop.run ();
		}
	}
}
