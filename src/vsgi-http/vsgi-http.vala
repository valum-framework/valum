/*
 * This file is part of Valum.
 *
 * Valum is free software: you can redistribute it and/or modify it under the
 * terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) any
 * later version.
 *
 * Valum is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with Valum.  If not, see <http://www.gnu.org/licenses/>.
 */

using GLib;
using Soup;

#if INCLUDE_TYPE_MODULE
[ModuleInit]
public Type plugin_init (TypeModule type_module) {
	return typeof (VSGI.HTTP.Server);
}
#endif

/**
 * HTTP implementation of VSGI.
 *
 * @since 0.1
 */
[CCode (gir_namespace = "VSGI.HTTP", gir_version = "0.2")]
namespace VSGI.HTTP {

	private class MessageBodyOutputStream : OutputStream {

		public Soup.Server server { construct; get; }

		public Soup.Message message { construct; get; }

		public MessageBodyOutputStream (Soup.Server server, Message message) {
			Object (server: server, message: message);
		}

		public override ssize_t write (uint8[] data, Cancellable? cancellable = null) {
			message.response_body.append_take (data);
			return data.length;
		}

		/**
		 * Resume I/O on the underlying {@link Soup.Message} to flush the
		 * written chunks.
		 */
		public override bool flush (Cancellable? cancellable = null) {
			server.unpause_message (message);
			return true;
		}

		public override bool close (Cancellable? cancellable = null) {
			message.response_body.complete ();
			return true;
		}
	}

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
		 * @param connection contains the connection obtain from
		 *                   {@link Soup.ClientContext.steal_connection} or a
		 *                   stud if it is not available
		 * @param msg        message underlying this request
		 * @param query      parsed HTTP query provided by {@link Soup.ServerCallback}
		 */
		public Request (IOStream connection, Message msg, HashTable<string, string>? query) {
			Object (connection: connection, message: msg);
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

		public override string? reason_phrase {
			owned get { return this.message.reason_phrase; }
			set { this.message.reason_phrase = value ?? Status.get_phrase (this.message.status_code); }
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
		public Response (Request req, Message msg) {
			Object (request: req, message: msg);
		}

		/**
		 * {@inheritDoc}
		 *
		 * Implementation based on {@link Soup.Message} already handles the
		 * writing of the status line and headers, so an empty buffer is
		 * returned.
		 */
		protected override uint8[]? build_head () { return null; }
	}

	/**
	 * Implementation of VSGI.Server based on Soup.Server.
	 *
	 * @since 0.1
	 */
	public class Server : VSGI.Server {

		private Soup.Server server;

		/**
		 * {@inheritDoc}
		 */
		public Server (string application_id, owned ApplicationCallback application) {
			base (application_id, (owned) application);
		}

		construct {
#if GIO_2_40
			const OptionEntry[] entries = {
				// port options
				{"port",      'p', 0, OptionArg.INT,  null, "Listen to the provided TCP port", "3003"},
				{"all",       'a', 0, OptionArg.NONE, null, "Listen on all interfaces '--port'"},
				{"ipv4-only", '4', 0, OptionArg.NONE, null, "Only listen on IPv4 interfaces"},
				{"ipv6-only", '6', 0, OptionArg.NONE, null, "Only listen on IPv6 interfaces"},

				// fd options
				{"file-descriptor", 'f', 0, OptionArg.INT, null, "Listen to the provided file descriptor", "0"},

				// https options
				{"https",         0, 0, OptionArg.NONE,     null, "Listen for HTTPS connections rather than plain HTTP"},
				{"ssl-cert-file", 0, 0, OptionArg.FILENAME, null, "Path to a file containing a PEM-encoded certificate"},
				{"ssl-key-file",  0, 0, OptionArg.FILENAME, null, "Path to a file containing a PEM-encoded private key"},

				// headers options
				{"server-header", 'h', 0, OptionArg.STRING, null, "Value to use for the 'Server' header on Messages processed by this server"},
				{"raw-paths",     0,   0, OptionArg.NONE,   null, "Percent-encoding in the Request-URI path will not be automatically decoded"},

				{null}
			};
			this.add_main_option_entries (entries);
#endif
		}

		public override int command_line (ApplicationCommandLine command_line) {
#if GIO_2_40
			var options = command_line.get_options_dict ();

			if (options.contains ("port") && options.contains ("file-descriptor")) {
				command_line.printerr ("'--port' and '--file-descriptor' cannot be specified together\n");
				return 1;
			}

			var port = options.contains ("port") ?
				options.lookup_value ("port", VariantType.INT32).get_int32 () : 3003;

			var file_descriptor = options.contains ("file-descriptor") ?
				options.lookup_value ("file-descriptor", VariantType.INT32).get_int32 () : 0;
#else
			var port            = 3003;
#endif

#if GIO_2_40
			if (options.contains ("https")) {
				if (!options.contains ("ssl-cert-file") || !options.contains ("ssl-key-file")) {
					command_line.printerr ("both '--ssl-cert-file' and '--ssl-key-file' must be provided\n");
					return 1;
				}
#if SOUP_2_38
				TlsCertificate? tls_certificate = null;
				try {
					tls_certificate = new TlsCertificate.from_files (options.lookup_value ("ssl-cert-file", VariantType.BYTESTRING).get_bytestring (),
					                                                 options.lookup_value ("ssl-key-file", VariantType.BYTESTRING).get_bytestring ());
				} catch (GLib.Error err) {
					command_line.printerr ("%s\n", err.message);
					return 1;
				}
#endif
				this.server = new Soup.Server (
#if !SOUP_2_48
					SERVER_PORT,            port,
#endif
					SERVER_RAW_PATHS,       options.contains ("raw-paths"),
#if SOUP_2_38
					SERVER_TLS_CERTIFICATE, tls_certificate,
#else
					SERVER_SSL_CERT_FILE,   options.lookup_value ("ssl-cert-file", VariantType.BYTESTRING).get_bytestring (),
					SERVER_SSL_KEY_FILE,    options.lookup_value ("ssl-key-file", VariantType.BYTESTRING).get_bytestring (),
#endif
					SERVER_SERVER_HEADER, null);
			} else
#endif
			{
				this.server = new Soup.Server (
#if !SOUP_2_48
					SERVER_PORT, port,
#endif
#if GIO_2_40
					SERVER_RAW_PATHS, options.contains ("raw-paths"),
#endif
					SERVER_SERVER_HEADER, null);
			}

#if GIO_2_40
			if (options.contains ("server-header"))
				this.server.server_header = options.lookup_value ("server-header", VariantType.STRING).get_string ();
#endif

			// register a catch-all handler
			this.server.add_handler (null, (server, msg, path, query, client) => {
				var connection = new Connection (server, msg);

				msg.set_status (Status.OK);

				var req = new Request (connection, msg, query);
				var res = new Response (req, msg);

				dispatch (req, res);
			});

#if SOUP_2_48
			ServerListenOptions listen_options = 0;

			try {
#if GIO_2_40
				if (options.contains ("https"))
					listen_options |= ServerListenOptions.HTTPS;

				if (options.contains ("ipv4-only"))
					listen_options |= ServerListenOptions.IPV4_ONLY;

				if (options.contains ("ipv6-only"))
					listen_options |= ServerListenOptions.IPV6_ONLY;

				if (options.contains ("file-descriptor")) {
					this.server.listen_fd (file_descriptor, listen_options);
				} else if (options.contains ("all")) {
					this.server.listen_all (port, listen_options);
				} else
#endif
				{
					this.server.listen_local (port, listen_options);
				}
			} catch (Error err) {
				command_line.printerr ("%s\n", err.message);
				return 1;
			}

			foreach (var uri in this.server.get_uris ()) {
				command_line.print ("listening on '%s://%s:%u'\n", uri.scheme, uri.host, uri.port);
			}
#else
			this.server.run_async ();

			command_line.print ("listening on 'http://0.0.0.0:%u'\n", this.server.port);
#endif

			// keep the process alive
			this.hold ();

			return 0;
		}

		/**
		 * @since 0.2
		 */
		private class Connection : IOStream {

			private InputStream _input_stream;
			private OutputStream _output_stream;

			public Soup.Server server { construct; get; }

			public Message message { construct; get; }

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
			public Connection (Soup.Server server, Message message) {
				Object (server: server, message: message);

				this._input_stream  = new MemoryInputStream.from_data (message.request_body.flatten ().data, null);
				this._output_stream = new MessageBodyOutputStream (server, message);

				// prevent the server from completing the message
				this.server.pause_message (message);
			}

			~Connection () {
				// resume I/O operations
				this.server.unpause_message (message);
			}
		}
	}
}
