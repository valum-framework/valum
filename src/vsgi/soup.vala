using Soup;

/**
 * Soup implementation of VSGI.
 */
[CCode (gir_namespace = "VSGI.Soup", gir_version = "0.1")]
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
				// port options
				{"port",      'p', 0, OptionArg.INT,  null, "port the server is listening on", "3003"},
				{"all",       'a', 0, OptionArg.NONE, null, "listen on all interfaces '--port'"}, // only with '--port'
				{"ipv4-only", '4', 0, OptionArg.NONE, null, "only listen to IPv4 interfaces"}, // only with '--port'
				{"ipv6-only", '6', 0, OptionArg.NONE, null, "only listen on IPv6 interfaces"}, // only with '--port'

				// fd options
				{"file-descriptor", 'f', 0, OptionArg.INT, null, "listen to the provided file descriptor", "0"},

				// https options
				{"https",           0, 0, OptionArg.NONE,     null, "listen for https connections rather than plain http"},
				{"ssl-cert-file",   0, 0, OptionArg.FILENAME, null, "path to a file containing a PEM-encoded certificate"},
				{"ssl-key-file",    0, 0, OptionArg.FILENAME, null, "path to a file containing a PEM-encoded private key"},

				// headers options
				{"server-header", 'h', 0, OptionArg.STRING, null, "value to use for the 'Server' header on Messages processed by this server", "Valum/0.1"},
				{"raw-paths",     0,   0, OptionArg.NONE,   null, "percent-encoding in the Request-URI path will not be automatically decoded"},

				// various options
				{"timeout", 't', 0, OptionArg.INT, null, "inactivity timeout in ms"},
				{null}
			};
			this.add_main_option_entries (entries);
#endif
		}

		public override int command_line (ApplicationCommandLine command_line) {
#if GIO_2_40
			var options = command_line.get_options_dict ();

			if (options.contains ("port") && options.contains ("file-descriptor"))
				error ("'--port' and '--file-descriptor' cannot be specified together");

			var port = options.contains ("port") ?
				options.lookup_value ("port", VariantType.INT32).get_int32 () :
				3003;

			var file_descriptor = options.contains ("file-descriptor") ?
				options.lookup_value ("file-descriptor", VariantType.INT32).get_int32 () :
				0;

			var server_header = options.contains ("server-header") ?
				options.lookup_value ("server-header", VariantType.STRING).get_string () :
				"Valum/0.1";

			ServerListenOptions listen_options = 0;

			if (options.contains ("https"))
				listen_options |= ServerListenOptions.HTTPS;

			if (options.contains ("ipv4-only"))
				listen_options |= ServerListenOptions.IPV4_ONLY;

			if (options.contains ("ipv6-only"))
				listen_options |= ServerListenOptions.IPV6_ONLY;

			if (options.contains ("timeout"))
				this.set_inactivity_timeout (options.lookup_value ("timeout", VariantType.INT32).get_int32 ());
#else
			var port            = 3003;
			var file_descriptor = 0;
			var server_header   = "Valum/0.1";
#endif

			this.hold ();

#if GIO_2_40
			if (options.contains ("https")) {
				this.server = new global::Soup.Server (
#if !SOUP_2_48
					global::Soup.SERVER_PORT, port,
#endif
					global::Soup.SERVER_RAW_PATHS,     options.contains ("raw-paths"),
					global::Soup.SERVER_SERVER_HEADER, server_header,
					global::Soup.SERVER_SSL_CERT_FILE, options.lookup_value ("ssl-cert-file", VariantType.BYTESTRING).get_bytestring (),
					global::Soup.SERVER_SSL_KEY_FILE,  options.lookup_value ("ssl-key-file", VariantType.BYTESTRING).get_bytestring ());
			} else
#endif
			{
				this.server = new global::Soup.Server (
#if !SOUP_2_48
					global::Soup.SERVER_PORT, port,
#endif
#if GIO_2_40
					global::Soup.SERVER_RAW_PATHS, options.contains ("raw-paths"),
#endif
					global::Soup.SERVER_SERVER_HEADER, server_header);
			}

#if GIO_2_40
			if (options.contains ("https")) {
				this.server.set_ssl_cert_file (options.lookup_value ("ssl-cert-file", VariantType.BYTESTRING).get_bytestring (),
				                               options.lookup_value ("ssl-key-file", VariantType.BYTESTRING).get_bytestring ());
			}
#endif

			// register a catch-all handler
			this.server.add_handler (null, (server, msg, path, query, client) => {
				this.hold ();

				var req = new Request (msg, query);
				var res = new Response (req, msg);

				this.application.handle (req, res);

				debug ("%s: %u %s %s", this.get_application_id (), res.status, req.method, req.uri.get_path ());

				this.release ();
			});

#if SOUP_2_48
#if GIO_2_40
			if (options.contains ("file-descriptor")) {
				this.server.listen_fd (file_descriptor, listen_options);
			} else if (options.contains ("all")) {
				this.server.listen_all (port, listen_options);
			} else
#endif
			{
				this.server.listen_local (port, listen_options);
			}

			foreach (var uri in this.server.get_uris ()) {
				message ("listening on %s://%s:%u", uri.scheme, uri.host, uri.port);
			}
#else
			this.server.run_async ();

			message ("listening on %s://%s:%u", this.server.@interface.protocol,
			                                    this.server.@interface.name,
			                                    this.server.@interface.port);
#endif

#if GIO_2_40
			if (options.contains ("timeout"))
				this.release ();
#endif

			return 0;
		}
	}
}
