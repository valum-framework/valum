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
	public class Request : VSGI.Request {

		private HashTable<string, string>? _query;

		/**
		 * Message underlying this request.
		 *
		 * @since 0.2
		 */
		public Message message { construct; get; }

		public override HTTPVersion http_version { get { return this.message.http_version; } }

		public override string method { owned get { return this.message.method ; } }

		public override URI uri { get { return this.message.uri; } }

		public override HashTable<string, string>? query { get { return this._query; } }

		public override MessageHeaders headers {
			get {
				return this.message.request_headers;
			}
		}

		/**
		 * {@inheritDoc}
		 *
		 * @since 0.2
		 *
		 * @param msg        message underlying this request
		 * @param connection contains the connection obtain from
		 *                   {@link Soup.ClientContext.steal_connection} or a
		 *                   stud if it is not available
		 * @param query      parsed HTTP query provided by {@link Soup.ServerCallback}
		 */
		public Request (Message msg, IOStream connection, HashTable<string, string>? query) {
			Object (message: msg, connection: connection);
			this._query = query;
		}
	}

	/**
	 * Soup Response
	 */
	public class Response : VSGI.Response {

		/**
		 * Message underlying this response.
		 *
		 * @since 0.2
		 */
		public Message message { construct; get; }

		public override uint status {
			get { return this.message.status_code; }
			set { this.message.set_status (value); }
		}

		public override MessageHeaders headers {
			get { return this.message.response_headers; }
		}

		/**
		 * {@inheritDoc}
		 *
		 * @since 0.2
		 *
		 * @param msg message underlying this response
		 */
		public Response (Request req, Message msg, IOStream connection) {
			Object (request: req, message: msg, connection: connection);
		}

#if SOUP_2_50
		/**
		 * Placeholder for the filtered body.
		 */
		private OutputStream? filtered_body = null;
#endif

		/**
		 * {@inheritDoc}
		 *
		 * If libsoup-2.4 (>=2.50) is available and the http_version in the
		 * {@link Request} is set to 'HTTP/1.1', chunked encoding will be
		 * applied.
		 */
		protected override OutputStream body {
			get {
				if (!this.head_written)
					this.write_head ();

#if SOUP_2_50
				if (this.filtered_body != null)
					return this.filtered_body;

				// filter the stream properly
				if (this.request.http_version == HTTPVersion.@1_1 && this.headers.get_encoding () == Encoding.CHUNKED) {
					this.filtered_body = new ConverterOutputStream (this.connection.output_stream, new ChunkedConverter ());
				} else {
					this.filtered_body = this.connection.output_stream;
				}

				return this.filtered_body;
#else
				return this.connection.output_stream;
#endif
			}
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
		public Server (ApplicationCallback application) {
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
#if SOUP_2_50
				var stolen_connection = client.steal_connection ();
				// the request stream have already been consumed by the server,
				// so we simply wrap it.
				var simple_connection = new SimpleIOStream (new MemoryInputStream.from_data (msg.request_body.data, null),
				                                            stolen_connection.output_stream);
				var req               = new Request (msg, simple_connection, query);
				var res               = new Response (req, msg, stolen_connection);
#else
				var connection = new Connection (server, msg);
				var req        = new Request (msg, connection, query);
				var res        = new Response (req, msg, connection);
#endif

				this.application (req, res);

				message ("%s: %u %s %s", this.get_application_id (), res.status, req.method, req.uri.get_path ());
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

#if !SOUP_2_50
		/**
		 * Represents a connection between the server and the client for older
		 * version of libsoup-2.4 (<2.50). It essentially complements the lack
		 * of {@link Soup.ClientContext.steal_connection}.
		 *
		 * @since 0.2
		 */
		private class Connection : IOStream {

			private InputStream _input_stream;
			private OutputStream _output_stream;

			public global::Soup.Server server { construct; get; }

			public global::Soup.Message message { construct; get; }

			public override InputStream input_stream {
				get {
					return this._input_stream;
				}
			}

			public override OutputStream output_stream {
				get {
					return this._output_stream;
				}
			}

			/**
			 * {@inheritDoc}
			 *
			 * @param server  used to pause and unpause the message from and
			 *                until the connection lives
			 * @param message message wrapped to provide the IOStream
			 */
			public Connection (global::Soup.Server server, global::Soup.Message message) {
				Object (server: server, message: message);

				this._input_stream  = new MemoryInputStream.from_data (message.request_body.data, null);
				this._output_stream = new MemoryOutputStream (message.response_body.data, realloc, free);

				// prevent the server from completing the message
				this.server.pause_message (message);
			}

			~Connection () {
				// explicitly complete the body
				this.message.response_body.complete ();

				// resume I/O operations
				this.server.unpause_message (message);
			}
		}
#endif
	}
}
