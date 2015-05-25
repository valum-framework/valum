using Soup;

/**
 * Soup implementation of VSGI.
 *
 * @since 0.1
 */
namespace VSGI.Soup {

	/**
	 * Soup Request
	 */
	class Request : VSGI.Request {

		private HashTable<string, string>? _query;

		public override HTTPVersion http_version { get { return this.message.http_version; } }

		public Message message { construct; get; }

		public override string method { owned get { return this.message.method ; } }

		public override URI uri { get { return this.message.uri; } }

		public override HashTable<string, string>? query { get { return this._query; } }

		public override MessageHeaders headers {
			get {
				return this.message.request_headers;
			}
		}

		public Request (Message msg, InputStream body, HashTable<string, string>? query) {
			Object (message: msg, body: body);
			this._query = query;
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

		public Response (Request req, Message msg, OutputStream raw_body) {
			Object (request: req, message: msg, raw_body: raw_body);
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

				var connection = client.steal_connection ();

				var req = new Request (msg, new MemoryInputStream.from_data (msg.request_body.data, null), query);
				var res = new Response (req, msg, connection.output_stream);

				res.end.connect_after (() => {
					connection.close_async (Priority.DEFAULT, null, () => {
						message ("%s: %u %s %s", get_application_id (), res.status, res.request.method, res.request.uri.get_path ());
						this.release ();
					});
				});

				this.application.handle (req, res);
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
