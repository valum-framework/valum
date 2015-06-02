using FastCGI;
using Soup;

/**
 * FastCGI implementation of VSGI.
 *
 * @since 0.1
 */
namespace VSGI.FastCGI {
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

		private HTTPVersion _http_version = HTTPVersion.@1_0;
		private string _method = VSGI.Request.GET;
		private URI _uri = new URI (null);
		private HashTable<string, string>? _query = null;
		private MessageHeaders _headers = new MessageHeaders (MessageHeadersType.REQUEST);

		public override HTTPVersion http_version {
			get { return this._http_version; }
		}

		public override string method {
			owned get { return this._method; }
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

		public Request (GLib.Socket socket, global::FastCGI.request request) {
			Object (base_stream: new StreamInputStream (socket, request.in));

			var environment = request.environment;

			if (environment["SERVER_PROTOCOL"] != null)
				this._http_version = environment["SERVER_PROTOCOL"] == "HTTP/1.1" ?
					HTTPVersion.@1_1 :
					HTTPVersion.@1_0; // fallback if it's not reckognized

			if (environment["REQUEST_METHOD"] != null)
				this._method = (string) environment["REQUEST_METHOD"];

			if (environment["HTTPS"] != null && environment["HTTPS"] == "on")
				this._uri.set_scheme ("https");

			this._uri.set_user (environment["REMOTE_USER"]);
			this._uri.set_host (environment["SERVER_NAME"]);

			if (environment["SERVER_PORT"] != null)
				this._uri.set_port (int.parse (environment["SERVER_PORT"]));

			if (environment["PATH_INFO"] != null)
				this._uri.set_path ((string) environment["PATH_INFO"]);

			// some server provide this one for the path
			if (environment["REQUEST_URI"] != null)
				this._uri.set_path ((string) environment["REQUEST_URI"]);

			this._uri.set_query (environment["QUERY_STRING"]);

			// parse the HTTP query
			if (environment["QUERY_STRING"] != null)
				this._query = Form.decode ((string) environment["QUERY_STRING"]);

			var headers = new StringBuilder ();

			// extract HTTP headers, they are prefixed by 'HTTP_' in environment variables
			foreach (var variable in environment.get_all ()) {
				if (variable.has_prefix ("HTTP_")) {
					var parts = variable.split("=", 2);
					headers.append ("%s: %s\r\n".printf(parts[0].substring(5).replace("_", "-").casefold(), parts[1]));
				}
			}

			global::Soup.headers_parse (headers.str, (int) headers.len, this._headers);
		}
	}

	/**
	 * FastCGI Response
	 */
	class Response : VSGI.Response {

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

		public Response (Request req, GLib.Socket socket, Stream @out, Stream err) {
			Object (request: req, base_stream: new StreamOutputStream (socket, @out, err));
		}

		/**
		 * The status line is part of the headers, so nothing has to be done here.
		 */
		protected override ssize_t write_status_line () throws IOError {
			return 0;
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
		public GLib.Socket? socket { get; set; default = null; }

		public Server (VSGI.Application application) {
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

			var source = new IOSource (new IOChannel.unix_new (socket.fd), IOCondition.IN);

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

				var req = new Request (this.socket, request);
				var res = new Response (req, this.socket, request.out, request.err);

				res.end.connect_after (() => {
					request.finish ();
					request.close (false); // keep the socket open
					message ("%s: %u %s %s", get_application_id (), res.status, res.request.method, res.request.uri.get_path ());
					this.release ();
				});

				this.application.handle (req, res);

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
