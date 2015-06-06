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

		public Request (HashTable<string, string> environment, InputStream base_stream) {
			Object (environment: environment, base_stream: base_stream);

			// 'PATH_TRANSLATED' contains all the important information, but the
			// server may not provide it.
			if (environment.contains ("PATH_TRANSLATED")) {
				this._uri = new URI (environment["PATH_TRANSLATED"]);
			} else {
				this._uri.set_host (environment["SERVER_NAME"]);
				this._uri.set_port (int.parse (environment["SERVER_PORT"]));
				this._uri.set_path (environment["PATH_INFO"]);
			}

			// raw HTTP query
			this._uri.set_query (environment["QUERY_STRING"]);

			// parsed HTTP query
			if (environment.contains ("QUERY_STRING"))
				this._query = Form.decode (environment["QUERY_STRING"]);

			// authentication information
			if (environment.contains ("REMOTE_USER"))
				this._uri.set_user (environment["REMOTE_USER"]);

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

		public Response (Request request, OutputStream base_stream) {
			Object (request: request, base_stream: base_stream);
		}

		/**
		 * The status line is part of the headers, so nothing has to be done here.
		 */
		protected override ssize_t write_status_line () throws IOError {
			return 0;
		}
	}

	public class Server : VSGI.Server {

		public Server (VSGI.Application application) {
			Object (application: application, flags: ApplicationFlags.HANDLES_COMMAND_LINE);
		}

		/**
		 * Handles a single request and qu
		 */
		public override int command_line (ApplicationCommandLine command_line) {
			var environment = new HashTable<string, string> (str_hash, str_equal);

			foreach (var variable in command_line.get_environ ()) {
				var parts = variable.split ("=", 2);
				environment[parts[0]] = parts.length == 2 ? parts[1] : "";
			}

			var req = new Request (environment, command_line.get_stdin ());
			var res = new Response (req, new MemoryOutputStream.resizable ());

			this.hold ();

			res.end.connect_after (() => {
				this.release ();
			});

			// handle a single request and quit
			application.handle (req, res);

			return 0;
		}
	}
}
