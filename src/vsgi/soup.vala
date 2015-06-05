using Soup;

/**
 * Soup implementation of VSGI.
 */
namespace VSGI.Soup {

	/**
	 * Soup Request
	 */
	class Request : VSGI.Request {

		public Message message { construct; get; }

		private HashTable<string, string>? _query;

		public override HTTPVersion http_version { get { return this.message.http_version; } }

		public override string method { owned get { return this.message.method ; } }

		public override URI uri { get { return this.message.uri; } }

		public override HashTable<string, string>? query { get { return this._query; } }

		public override MessageHeaders headers {
			get {
				return this.message.request_headers;
			}
		}

		public Request (Message msg, HashTable<string, string>? query) {
			Object (message: msg);
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

		public Message message { construct; get; }

		public override uint status {
			get { return this.message.status_code; }
			set { this.message.set_status (value); }
		}

		public override MessageHeaders headers {
			get { return this.message.response_headers; }
		}

		public Response (Request req, Message msg) {
			Object (request: req, message: msg);
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

		/**
		 * {@inheritDoc}
		 */
		public Server (VSGI.Application application) {
			base (application);

#if GIO_2_40
			const OptionEntry[] entries = {
				{"port", 'p', 0, OptionArg.INT, null, "port used to serve the HTTP server", "3003"},
				{"timeout", 't', 0, OptionArg.INT, null, "inactivity timeout in ms", "0"},
				{null}
			};
			this.add_main_option_entries (entries);
#endif
		}

		public override int command_line (ApplicationCommandLine command_line) {
#if GIO_2_40
			var options = command_line.get_options_dict ();

			if (options.contains ("port") && options.contains ("socket"))
				error ("either port or socket can be specified, not both");

			var port    = options.contains ("port") ? options.lookup_value ("port", VariantType.INT32).get_int32 () : 3003;
			var timeout = options.contains ("timeout") ? options.lookup_value ("timeout", VariantType.INT32).get_int32 () : 0;
#else
			var port    = 3003;
			var timeout = 0;
#endif

			this.set_inactivity_timeout (timeout);

#if SOUP_2_48
			this.server = new global::Soup.Server (global::Soup.SERVER_SERVER_HEADER, "Valum");
#else
			this.server = new global::Soup.Server (global::Soup.SERVER_SERVER_HEADER, "Valum",
			                                       global::Soup.SERVER_PORT, port);
#endif

			this.hold ();

			// register a catch-all handler
			this.server.add_handler (null, (server, msg, path, query, client) => {
				this.hold ();

				var req = new Request (msg, query);
				var res = new Response (req, msg);

				this.application.handle (req, res);

				message ("%s: %u %s %s", this.get_application_id (), res.status, req.method, req.uri.get_path ());

				this.release ();
			});

#if SOUP_2_48
			this.server.listen_all (port, 0);

			foreach (var uri in this.server.get_uris ()) {
				message ("listening on %s://%s:%u", uri.scheme, uri.host, uri.port);
			}
#else
			this.server.run_async ();
			message ("listening on http://0.0.0.0:%u", this.server.port);
#endif

			// keep alive if timeout is 0
			if (this.get_inactivity_timeout () > 0)
				this.release ();

			return 0; // continue processing
		}
	}
}
