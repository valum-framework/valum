using FastCGI;
using Soup;

/**
 * FastCGI implementation of VSGI.
 */
namespace VSGI.FastCGI {
	/**
	 * FastCGI Request implementation.
	 *
	 * The request keeps a strong reference to its inner {@link FastCGI.request} so
	 * that it is being freed only when any processing involving this._request is
	 * done.
	 *
	 * The constructor will block until a request is accepted so that the object can
	 * exclusively own the {@link FastCGI.request} instance.
	 */
	class Request : VSGI.Request {

		private string _method = VSGI.Request.GET;
		private URI _uri = new URI (null);
		private HashTable<string, string>? _query = null;
		private MessageHeaders _headers = new MessageHeaders (MessageHeadersType.REQUEST);

		public global::FastCGI.request _request;

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

		public Request (GLib.Socket socket) {
			var request_status = global::FastCGI.request.init (out this._request, socket.fd);

			if (request_status != 0)
				error ("code %u: could not initialize FCGX request".printf (request_status));

			var status = this._request.accept ();

			if (status < 0) {
				this._request.close ();
				error ("request %u: cannot not accept anymore request (status %u)", this._request.request_id, status);
			}

			var environment = this._request.environment;

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

			// extract HTTP headers, they are prefixed by 'HTTP_' in environment variables
			foreach (var variable in this._request.environment.get_all ()) {
				if (variable.has_prefix ("HTTP_")) {
					var parts = variable.split("=", 2);
					headers.append ("%s: %s\r\n".printf(parts[0].substring(5).replace("_", "-").casefold(), parts[1]));
				}
			}

			global::Soup.headers_parse (headers.str, (int) headers.len, this._headers);
		}

		/**
		 * Finish and close the {@link FastCGI.request} instance.
		 */
		~Request () {
			this._request.finish ();
			this._request.close (false); // keep the socket open
		}

		public override ssize_t read (uint8[] buffer, Cancellable? cancellable = null) throws IOError {
			var read = this._request.in.read (buffer);

			if (read == GLib.FileStream.EOF)
				throw new Error (IOError.quark (), FileUtils.error_from_errno (this._request.in.get_error ()), strerror (FileUtils.error_from_errno (this._request.in.get_error ())));

			return read;
		}

		public override bool close (Cancellable? cancellable = null) throws IOError {
			if (this._request.in.close () == -1)
				throw new Error (IOError.quark (), FileUtils.error_from_errno (this._request.in.get_error ()), strerror (FileUtils.error_from_errno (this._request.in.get_error ())));

			return this._request.in.is_closed;
		}
	}

	/**
	 * FastCGI Response
	 */
	class Response : VSGI.Response {

		private unowned Stream @out;
		private unowned Stream err;

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

		public Response (Request req, Stream @out, Stream err) {
			Object (request: req);
			this.out = @out;
			this.err = err;
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
			var written = this.out.puts (headers.str);

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

			var written = this.out.put_str (buffer);

			if (written == GLib.FileStream.EOF)
				throw new Error (IOError.quark (), FileUtils.error_from_errno (this.out.get_error ()), strerror (FileUtils.error_from_errno (this.out.get_error ())));

			return written;
		}

		/**
		 * Headers are written on the first flush call.
		 */
		public override bool flush (Cancellable? cancellable = null) {
			return this.out.flush ();
		}

		public override bool close (Cancellable? cancellable = null) throws IOError {
			// lock so that two threads would not write headers at the same time.
			lock (this.headers_written) {
				if (!this.headers_written)
					this.write_headers ();
			}

			if (this.err.close () == -1)
				throw new Error (IOError.quark (), FileUtils.error_from_errno (this.err.get_error ()), strerror (FileUtils.error_from_errno (this.err.get_error ())));

			if (this.out.close () == -1)
				throw new Error (IOError.quark (), FileUtils.error_from_errno (this.out.get_error ()), strerror (FileUtils.error_from_errno (this.out.get_error ())));

			return this.err.is_closed && this.out.is_closed;
		}
	}

	/**
	 * FastCGI Server using GLib.MainLoop.
	 *
	 * @since 0.1
	 */
	public class Server : VSGI.Server {

		/**
		 * FastCGI socket file descriptor.
		 */
		private GLib.Socket socket;

		public Server (VSGI.Application application) {
			Object (application: application);

			this.add_main_option ("socket", 's', 0, OptionArg.STRING, "path to the UNIX socket", null);
			this.add_main_option ("port", 'p', 0, OptionArg.INT, "TCP port on this host", null);
			this.add_main_option ("backlog", 'b', 0, OptionArg.INT, "listen queue depth used in the listen() call", "0");

			this.startup.connect (() => {
				var status = init ();
				if (status != 0)
					error ("code %u: failed to initialize FCGX library".printf (status));
			});

			this.shutdown.connect (shutdown_pending);
		}

		public override int handle_local_options (VariantDict options) {
			if (options.contains ("socket") && options.contains ("port")) {
				GLib.stderr.printf ("--socket and --port must not be specified simultaneously");
				return 1;
			}

			var backlog = options.contains ("backlog") ? options.lookup_value ("backlog", VariantType.INT32).get_int32 () : 0;
			var timeout = options.contains ("timeout") ? options.lookup_value ("timeout", VariantType.INT32).get_int32 () : 60000;

			this.set_inactivity_timeout (timeout);

			if (options.contains ("socket")) {
				var socket_path = options.lookup_value ("socket", VariantType.STRING).get_string ();
				this.socket     = new GLib.Socket.from_fd (open_socket (socket_path, backlog));

				if (!this.socket.is_connected ())
					error ("could not open socket path %s".printf (socket_path));

				message ("listening on %s (backlog %d)", socket_path, backlog);
			}

			else if (options.contains ("port")) {
				var port   = ":%d".printf(options.lookup_value ("port", VariantType.INT32).get_int32 ());
				this.socket = new GLib.Socket.from_fd (open_socket (port, backlog));

				if (!this.socket.is_connected ())
					error ("could not open TCP socket at port %s".printf (port));

				message ("listening on tcp://0.0.0.0:%s (backlog %d)", port, backlog);
			}

			else {
				// we just need to know the socket file descriptor...
				request req;
				request.init (out req);

				this.socket = new GLib.Socket.from_fd (req.listen_socket);

				// ...
				req.close (false);

				message ("listening the default socket");
			}

			return -1; // continue processing
		}


		/**
		 * Handle the command line and setup the request.
		 */
		public override void activate () {
			this.hold ();

			var source = new IOSource (new IOChannel.unix_new (socket.fd), IOCondition.IN);

			source.set_callback (() => {
				this.hold ();

				var req = new Request (this.socket);
				var res = new Response (req, req._request.out, req._request.err);

				this.application.handle.begin (req, res, () => {
					message ("%s: %u %s %s", this.get_application_id (), res.status, req.method, req.uri.get_path ());
					this.release ();
				});

				return true;
			});

			source.attach (MainContext.default ());

			this.release ();
		}
	}
}
