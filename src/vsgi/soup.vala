using Soup;

/**
 * Soup implementation of VSGI.
 */
namespace VSGI.Soup {

	/**
	 * Soup Request
	 */
	class Request : VSGI.Request {

		private Message message;
		private HashTable<string, string>? _query;

		public override string method { owned get { return this.message.method ; } }

		public override URI uri { get { return this.message.uri; } }

		public override HashTable<string, string>? query { get { return this._query; } }

		public override MessageHeaders headers {
			get {
				return this.message.request_headers;
			}
		}

		public Request (Message msg, HashTable<string, string>? query) {
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
	class Response : VSGI.Response {

		private Message message;

		public override uint status {
			get { return this.message.status_code; }
			set { this.message.set_status (value); }
		}

		public override MessageHeaders headers {
			get { return this.message.response_headers; }
		}

		public Response (Request req, Message msg) {
			Object (request: req);
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
	public class Server : VSGI.Server {

		private global::Soup.Server server;

		public Server (VSGI.Application application) {
			Object (application: application);

			this.server = new global::Soup.Server (global::Soup.SERVER_SERVER_HEADER, "Valum");

			this.add_main_option ("port", 'p', 0, OptionArg.INT, "port used to serve the HTTP server", "3003");
			this.add_main_option ("timeout", 't', 0, OptionArg.INT, "inactivity timeout in ms", "60000");
		}

		public override int handle_local_options (VariantDict options) {
			var port    = options.contains ("port") ? options.lookup_value ("port", VariantType.INT32).get_int32 () : 3003;
			var timeout = options.contains ("timeout") ? options.lookup_value ("timeout", VariantType.INT32).get_int32 () : 60000;

			this.server.listen_all (port, 0);
			this.set_inactivity_timeout (timeout);

			return -1; // continue processing
		}

		public override void activate () {
			this.hold ();

			// register a catch-all handler
			this.server.add_handler (null, (server, msg, path, query, client) => {
				this.hold ();

				var req = new Request (msg, query);
				var res = new Response (req, msg);

				this.application.handle.begin (req, res, () => {
					message ("%s: %u %s %s", this.get_application_id (), res.status, req.method, req.uri.get_path ());
					this.release ();
				});
			});

			foreach (var uri in this.server.get_uris ()) {
				message ("listening on %s://%s:%u", uri.scheme, uri.host, uri.port);
			}

			this.release ();
		}
	}
}
