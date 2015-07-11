using GLib;
using Soup;

/**
 * CGI implementation of VSGI.
 *
 * This implementation is sufficiently general to implement other CGI-like
 * protocol such as FastCGI and SCGI.
 *
 * @since 0.2
 */
namespace VSGI.CGI {

	public class Request : VSGI.Request {

		/**
		 * CGI environment variables.
		 */
		public HashTable<string, string> environment { construct; get; }

		private URI _uri                          = new URI (null);
		private HashTable<string, string>? _query = null;
		private MessageHeaders _headers           = new MessageHeaders (MessageHeadersType.REQUEST);

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

		public Request (IOStream connection, HashTable<string, string> environment) {
			Object (connection: connection, environment: environment);

			// authentication information
			if (environment.contains ("REMOTE_USER"))
				this._uri.set_user (environment["REMOTE_USER"]);

			this._uri.set_host (environment["SERVER_NAME"]);

			if (environment.contains ("SERVER_PORT"))
				this._uri.set_port (int.parse (environment["SERVER_PORT"]));

			if (environment.contains ("PATH_INFO"))
				this._uri.set_path (environment["PATH_INFO"]);
			else
				this._uri.set_path ("/");

			// raw HTTP query
			this._uri.set_query (environment["QUERY_STRING"]);

			// parsed HTTP query
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

	public class Response : VSGI.Response {

		private MessageHeaders _headers = new MessageHeaders (MessageHeadersType.RESPONSE);

		public override uint status {
			get {
				// the code is exactly three digit and since the value is expected
				// to be setted, it is not important to perform a null-check
				return int.parse (this._headers.get_one ("Status").substring (0, 3));
			}
			set {
				// update the 'Status' header
				this._headers.replace ("Status", "%u %s".printf (value, Status.get_phrase (value)));
			}
		}

		public override MessageHeaders headers { get { return this._headers; } }

		public Response (Request request) {
			Object (request: request);
		}

		/**
		 * {@inheritDoc}
		 *
		 * CGI protocols does not have a status line. They use the 'Status'
		 * header instead.
		 */
		protected override uint8[]? build_head () {
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

	private class FileStreamInputStream : InputStream {

		public unowned FileStream file_stream { construct; get; }

		public FileStreamInputStream (FileStream file_stream) {
			Object (file_stream: file_stream);
		}

		public override ssize_t read (uint8[] data, Cancellable? cancellable = null) {
			return file_stream.read (data) == 1 ? data.length : 0;
		}

		public override bool close (Cancellable? cancellable = null) {
			return true;
		}
	}

	private class FileStreamOutputStream : OutputStream {

		public unowned FileStream file_stream { construct; get; }

		public FileStreamOutputStream (FileStream file_stream) {
			Object (file_stream: file_stream);
		}

		public override ssize_t write (uint8[] data, Cancellable? cancellable = null) {
			return file_stream.write (data) == 1 ? data.length : 0;
		}

		public override bool flush (Cancellable? cancellable = null) {
			return file_stream.flush () == 0;
		}

		public override bool close (Cancellable? cancellable = null) {
			return true;
		}
	}

	/**
	 * {@inheritDoc}
	 *
	 * Unlike other VSGI implementations, which are actively awaiting upon
	 * requests, CGI handles a single request and then wait until the underlying
	 * {@link GLib.Application} quits. Longstanding operations can invoke
	 * {@link GLib.Application.hold} and {@link GLib.Application.release} to
	 * keep the server alive as long as necessary.
	 */
	public class Server : VSGI.Server {

		public Server (VSGI.ApplicationCallback application) {
			base (application);
		}

		public override int command_line (ApplicationCommandLine command_line) {
			var environment = new HashTable<string, string> (str_hash, str_equal);

			foreach (var variable in command_line.get_environ ()) {
				var parts             = variable.split ("=", 2);
				environment[parts[0]] = parts.length == 2 ? parts[1] : "";
			}

			var connection = new Connection (this,
#if GIO_2_34
			                                 command_line.get_stdin (),
#else
			                                 new FileStreamInputStream (stdin),
#endif
			                                 new FileStreamOutputStream (stdout));

			var req = new Request (connection, environment);
			var res = new Response (req);

			// handle a single request and quit
			this.handle (req, res);

			return 0;
		}

		private class Connection : IOStream {

			private InputStream _input_stream;
			private OutputStream _output_stream;

			public Server server { construct; get; }

			public override InputStream input_stream { get { return this._input_stream; } }

			public override OutputStream output_stream { get { return this._output_stream; } }

			public Connection (Server server, InputStream input_stream, OutputStream output_stream) {
				Object (server: server);
				this._input_stream  = input_stream;
				this._output_stream = output_stream;
				this.server.hold ();
			}

			~Connection () {
				this.server.release ();
			}
		}
	}
}
