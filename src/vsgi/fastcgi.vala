using FastCGI;
using Soup;

/**
 * FastCGI implementation of VSGI.
 *
 * @since 0.1
 */
namespace VSGI.FastCGI {

	/**
	 * InputStream wrapper around {@link FastCGI.Stream}.
	 */
	class StreamInputStream : InputStream, PollableInputStream {

		public GLib.Socket socket { construct; get; }

		public unowned global::FastCGI.Stream @in { construct; get; }

		public StreamInputStream (GLib.Socket socket, global::FastCGI.Stream @in) {
			Object (socket: socket, @in: @in);
		}

		public override ssize_t read (uint8[] buffer, Cancellable? cancellable = null) throws IOError {
			var read = this.in.read (buffer);

			if (read == GLib.FileStream.EOF)
				throw new Error (IOError.quark (),
				                 FileUtils.error_from_errno (this.in.get_error ()),
				                 strerror (FileUtils.error_from_errno (this.in.get_error ())));

			return read;
		}

		public override bool close (Cancellable? cancellable = null) throws IOError {
			if (this.in.close () == -1)
				throw new Error (IOError.quark (),
				                 FileUtils.error_from_errno (this.in.get_error ()),
				                 strerror (FileUtils.error_from_errno (this.in.get_error ())));

			return this.in.is_closed;
		}

		public bool can_poll () {
			return true; // hope so!
		}

		public PollableSource create_source (Cancellable? cancellable = null) {
			var source = new PollableSource (this);
			source.add_child_source (this.socket.create_source (IOCondition.IN, cancellable));
			return source;
		}

		public bool is_readable () {
			return true;
		}

		public ssize_t read_nonblocking_fn (uint8[] buffer) throws Error {
			var read = this.in.read (buffer);

			if (read == GLib.FileStream.EOF)
				throw new Error (IOError.quark (),
				                 FileUtils.error_from_errno (this.in.get_error ()),
				                 strerror (FileUtils.error_from_errno (this.in.get_error ())));

			return read;
		}
	}

	/**
	 * OutputStream wrapper around {@link FastCGI.Stream}.
	 */
	class StreamOutputStream : OutputStream, PollableOutputStream {

		public GLib.Socket socket { construct; get; }

		public unowned global::FastCGI.Stream @out { construct; get; }

		public unowned global::FastCGI.Stream err { construct; get; }

		/**
		 * @param socket socket used to obtain {@link GLib.SocketSource}
		 */
		public StreamOutputStream (GLib.Socket socket, global::FastCGI.Stream @out, global::FastCGI.Stream err) {
			Object (socket: socket, @out: @out, err: err);
		}

		public override ssize_t write (uint8[] buffer, Cancellable? cancellable = null) throws IOError {
			var written = this.out.put_str (buffer);

			if (written == GLib.FileStream.EOF)
				throw new Error (IOError.quark (),
				                 FileUtils.error_from_errno (this.out.get_error ()),
				                 strerror (FileUtils.error_from_errno (this.out.get_error ())));

			return written;
		}

		/**
		 * Headers are written on the first flush call.
		 */
		public override bool flush (Cancellable? cancellable = null) {
			return this.out.flush ();
		}

		public override bool close (Cancellable? cancellable = null) throws IOError {
			if (this.out.close () == -1)
				throw new Error (IOError.quark (),
				                 FileUtils.error_from_errno (this.out.get_error ()),
				                 strerror (FileUtils.error_from_errno (this.out.get_error ())));

			if (this.err.close () == -1)
				throw new Error (IOError.quark (),
				                 FileUtils.error_from_errno (this.err.get_error ()),
				                 strerror (FileUtils.error_from_errno (this.err.get_error ())));

			return this.out.is_closed && this.err.is_closed;
		}

		public bool can_poll () {
			return true; // hope so!
		}

		public PollableSource create_source (Cancellable? cancellable = null) {
			var source = new PollableSource (this);
			source.add_child_source (this.socket.create_source (IOCondition.OUT, cancellable));
			return source;
		}

		public bool is_writable () {
			return true;
		}

		public ssize_t write_nonblocking (uint8[] buffer) throws Error {
			var written = this.out.put_str (buffer);

			if (written == GLib.FileStream.EOF)
				throw new Error (IOError.quark (),
				                 FileUtils.error_from_errno (this.out.get_error ()),
				                 strerror (FileUtils.error_from_errno (this.out.get_error ())));

			return written;
		}
	}

	/**
	 *
	 */
	class FastCGIConnection : IOStream {

		public GLib.Socket socket { construct; get; }

		private unowned global::FastCGI.request request;
		private StreamInputStream _input_stream;
		private StreamOutputStream _output_stream;

		public override InputStream input_stream {
			get {
				return _input_stream;
			}
		}

		public override OutputStream output_stream {
			get {
				return this._output_stream;
			}
		}

		public FastCGIConnection (GLib.Socket socket, global::FastCGI.request request) {
			Object (socket: socket);
			this.request        = request;
			this._input_stream  = new StreamInputStream (socket, request.in);
			this._output_stream = new StreamOutputStream (socket, request.out, request.err);
		}

		~FastCGIConnection () {
			request.finish ();
			request.close (false); // keep the socket open
		}
	}

	/**
	 * {@inheritDoc}
	 */
	public class Request : VSGI.Request {

		public HashTable<string, string> environment { construct; get; }

		private URI _uri = new URI (null);
		private HashTable<string, string>? _query = null;
		private MessageHeaders _headers = new MessageHeaders (MessageHeadersType.REQUEST);

		public override HTTPVersion http_version {
			get {
				return environment["SERVER_PROTOCOL"] == "HTTP/1.1" ?
					HTTPVersion.@1_1 :
					HTTPVersion.@1_0;
			}
		}

		public override string method {
			owned get {
				return this.environment["REQUEST_METHOD"];
			}
		}

		public override URI uri { get { return this._uri; } }

		public override HashTable<string, string>? query {
			get {
				return this._query;
			}
		}

		public override MessageHeaders headers {
			get { return this._headers; }
		}

		public Request (HashTable<string, string> environment , IOStream connection) {
			Object (environment: environment, connection: connection);

			if (environment.contains ("HTTPS") && environment["HTTPS"] == "on")
				this._uri.set_scheme ("https");

			this._uri.set_user (environment["REMOTE_USER"]);

			if (environment.contains ("SERVER_NAME"))
				this._uri.set_host (environment["SERVER_NAME"]);

			// fallback on the server address
			else if (environment.contains ("SERVER_ADDR"))
				this._uri.set_host (environment["SERVER_ADDR"]);

			if (environment.contains ("SERVER_PORT"))
				this._uri.set_port (int.parse (environment["SERVER_PORT"]));

			if (environment.contains ("REQUEST_URI"))
				this._uri.set_path (environment["REQUEST_URI"].split ("?", 2)[0]); // avoid the query

			// fallback on 'PATH_INFO'
			else if (environment.contains ("PATH_INFO"))
				this._uri.set_path (environment["PATH_INFO"]);

			this._uri.set_query (environment["QUERY_STRING"]);

			// parse the HTTP query
			if (environment.contains ("QUERY_STRING"))
				this._query = Form.decode (environment["QUERY_STRING"]);

			// extract HTTP headers, they are prefixed by 'HTTP_' in environment variables
			environment.foreach ((name, @value) => {
				if (name.has_prefix ("HTTP_")) {
					this.headers.append (name.substring (5).replace ("_", "-").casefold (), @value);
				}
			});
		}
	}

	/**
	 * {@inheritDoc}
	 */
	public class Response : VSGI.Response {

		private uint _status;

		private MessageHeaders _headers = new MessageHeaders (MessageHeadersType.RESPONSE);

		public override uint status {
			get { return this._status; }
			set {
				this._status = value;
				// update the 'Status' header
				this._headers.replace ("Status", "%u %s".printf (value, Status.get_phrase (value)));
			}
		}

		public override MessageHeaders headers { get { return this._headers; } }

		/**
		 * {@inheritDoc}
		 */
		public Response (Request req, IOStream connection) {
			Object (request: req, connection: connection);
		}

		/**
		 * {@inheritDoc}
		 *
		 * CGI protocols does not have a status line. They use the 'Status'
		 * header instead.
		 */
		public override uint8[] build_head () {
			var head = new StringBuilder ();

			// headers containing the status line
			this.headers.foreach ((k, v) => {
				head.append ("%s: %s\r\n".printf (k, v));
			});

			// newline preceeding the body
			head.append ("\r\n");

			return head.str.data;
		}
	}

	/**
	 * {@inheritDoc}
	 */
	public class Server : VSGI.Server {

		/**
		 * FastCGI socket file descriptor.
		 */
		public GLib.Socket? socket { get; set; default = null; }

		/**
		 * {@inheritDoc}
		 */
		public Server (ApplicationCallback application) {
			base (application);

#if GIO_2_40
			const OptionEntry[] options = {
				{"socket", 's', 0, OptionArg.STRING, null, "path to the UNIX socket", null},
				{"port", 'p', 0, OptionArg.INT, null, "TCP port on this host", null},
				{"backlog", 'b', 0, OptionArg.INT, null, "listen queue depth used in the listen() call", "0"},
				{"timeout", 't', 0, OptionArg.INT, null, "inactivity timeout in ms", "0" },
				{null}
			};
			this.add_main_option_entries (options);
#endif

			this.startup.connect (() => {
				var status = init ();
				if (status != 0)
					error ("code %u: failed to initialize FCGX library".printf (status));
			});

			this.shutdown.connect (global::FastCGI.shutdown_pending);
		}

		public override int command_line (ApplicationCommandLine command_line) {
#if GIO_2_40
			var options = command_line.get_options_dict ();

			if (options.contains ("socket") && options.contains ("port")) {
				GLib.stderr.printf ("--socket and --port must not be specified simultaneously");
				return 1;
			}

			var backlog = options.contains ("backlog") ? options.lookup_value ("backlog", VariantType.INT32).get_int32 () : 0;
			var timeout = options.contains ("timeout") ? options.lookup_value ("timeout", VariantType.INT32).get_int32 () : 0;

			this.set_inactivity_timeout (timeout);
#endif

#if GIO_2_40
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

			else
#endif
			{
				this.socket = new GLib.Socket.from_fd (0);
				message ("listening the default socket");
			}

			this.hold ();

			var source = socket.create_source (IOCondition.IN);

			source.set_callback (() => {
				this.hold ();

				global::FastCGI.request request;

				// accept a request
				var request_status = global::FastCGI.request.init (out request, socket.fd);

				if (request_status != 0)
					error ("code %u: could not initialize FCGX request".printf (request_status));

				var status = request.accept ();

				if (status < 0) {
					request.close ();
					error ("request %u: cannot not accept anymore request (status %u)", request.request_id, status);
				}

				var environment = new HashTable<string, string> (str_hash, str_equal);

				foreach (var e in request.environment.get_all ()) {
					var parts = e.split ("=", 2);
					environment[parts[0]] = parts.length == 2 ? parts[1] : "";
				}

				var connection = new FastCGIConnection (this.socket, request);

				var req = new Request (environment, connection);
				var res = new Response (req, connection);

				this.application (req, res);

				message ("%s: %u %s %s", this.get_application_id (), res.status, req.method, req.uri.get_path ());

				return true;
			});

			source.attach (MainContext.default ());

			// keep alive if there is no timeout
			if (this.get_inactivity_timeout () > 0)
				this.release ();

			return 0;
		}
	}
}
