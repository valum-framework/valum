using Soup;

/**
 * Soup implementation of VSGI.
 */
namespace VSGI {

	/**
	 * Request implementation based on libsoup.
	 */
	class SoupRequest : VSGI.Request {

		/**
		 * In-memory session implementation.
		 *
		 * This maps session id to session hashtable.
		 */
		private static HashTable<string, HashTable<string, string>> sessions = new HashTable<string, HashTable<string, string>> (str_hash, str_equal);

		private Soup.Message message;
		private HashTable<string, string>? _query;

		/**
		 * Find the session cookie if it exists.
		 *
		 * Minimally checks if the cookie is secure and not expired.
		 *
		 * @return null if the cookie is not found
		 */
		private Cookie? find_session_cookie () {
			var cookies = this.cookies;

			cookies.reverse ();

			foreach (var cookie in cookies) {
				if (cookie.name == "session" && cookie.secure && !cookie.expires.is_past ()) {
					return cookie;
				}
			}

			return null;
		}

		public override string method { owned get { return this.message.method ; } }

		public override URI uri { get { return this.message.uri; } }

		public override HashTable<string, string>? query { get { return this._query; } }

		public override MessageHeaders headers {
			get {
				return this.message.request_headers;
			}
		}

		public override HashTable<string, string>? session {
			owned get {
				var cookie = this.find_session_cookie ();

				// no cookie, no session
				if (cookie == null)
					return null;

				return sessions[((Cookie) cookie).value];
			}
			set {
				var cookie = this.find_session_cookie ();

				if (cookie == null && session == null)
					return;

				if (cookie == null) {
					// create a new cookie
					cookie = new Cookie ("session", NM.Utils.uuid_generate (), this.uri.get_host (), this.uri.get_path (), -1);
					this.headers.append ("Cookie", ((Cookie) cookie).to_cookie_header ());
				}

				var session_id = ((Cookie) cookie).value;

				if (value == null) {
					// delete the session
					sessions.remove (session_id);
				} else {
					// update the session
					sessions[session_id] = value;
				}
			}
		}

		public SoupRequest(Soup.Message msg, HashTable<string, string>? query) {
			this.message = msg;
			this._query = query;
		}

		/**
		 * Offset from which the response body is being read.
		 */
		private int64 offset = 0;

		public override ssize_t read (uint8[] buffer, Cancellable? cancellable = null) {
			var chunk = this.message.request_body.get_chunk (offset);

			/* potentially more data... */
			if (chunk == null)
				return -1;

			// copy the data into the buffer
			Memory.copy (buffer, chunk.data, chunk.length);

			offset += chunk.length;

			return (ssize_t) chunk.length;
		}

		/**
		 * This will complete the request MessageBody.
		 */
		public override bool close (Cancellable? cancellable = null) {
			this.message.request_body.complete ();
			return true;
		}
	}

	/**
	 * Soup Response
	 */
	class SoupResponse : VSGI.Response {

		private Soup.Message message;

		public override uint status {
			get { return this.message.status_code; }
			set { this.message.set_status (value); }
		}

		public override MessageHeaders headers {
			get { return this.message.response_headers; }
		}

		public SoupResponse (SoupRequest req, Soup.Message msg) {
			base (req);
			this.message = msg;
		}

		public override ssize_t write (uint8[] buffer, Cancellable? cancellable = null) {
			this.message.response_body.append_take (buffer);
			return buffer.length;
		}

		/**
		 * This will complete the response MessageBody.
         *
		 * Once called, you will not be able to alter the stream.
		 */
		public override bool close (Cancellable? cancellable = null) {
			this.message.response_body.complete ();
			return true;
		}
	}

	/**
	 * Implementation of VSGI.Server based on Soup.Server.
	 *
	 * @since 0.1
	 */
	public class SoupServer : VSGI.Server {

		private Soup.Server server;

		public SoupServer (VSGI.Application app, uint port) throws Error {
			base (app);
			this.server = new Soup.Server (Soup.SERVER_PORT, 3003);
		}

		/**
		 * Creates a Soup.Server, bind the application to it using a closure and
		 * start the server.
		 *
		 * The used implementation of server is deprecated, but requires to build
		 * under Travis CI.
		 */
		public override void listen () {

			Soup.ServerCallback soup_handler = (server, msg, path, query, client) => {

				var req = new SoupRequest (msg, query);
				var res = new SoupResponse (req, msg);

				this.application.handle (req, res);

				message ("%u %s %s".printf (res.status, req.method, req.uri.get_path ()));
			};

			this.server.add_handler (null, soup_handler);

			message ("listening on http://%s:%u", server.interface.physical, server.interface.port);

			// run the server
			this.server.run ();
		}
	}
}
