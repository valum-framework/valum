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

		public Request (IOStream connection, HashTable<string, string> environment) {
			Object (connection: connection, environment: environment);

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

		public Response (Request request) {
			Object (request: request);
		}

		/**
		 * {@inheritDoc}
		 *
		 * CGI protocols does not have a status line. They use the 'Status'
		 * header instead.
		 */
		public override uint8[]? build_head () {
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

	public class Server : VSGI.Server {

		public Server (VSGI.ApplicationCallback application) {
			base (application);
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

			var connection = new SimpleIOStream (command_line.get_stdin (),
			                                     new MemoryOutputStream.resizable ());

			var req = new Request (connection, environment);
			var res = new Response (req);

			// handle a single request and quit
			this.handle (req, res);

			this.hold ();

			return 0;
		}
	}
}
