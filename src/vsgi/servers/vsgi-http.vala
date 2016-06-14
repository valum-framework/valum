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

[ModuleInit]
public Type server_init (TypeModule type_module) {
	return typeof (VSGI.HTTP.Server);
}

/**
 * HTTP implementation of VSGI.
 *
 * @since 0.1
 */
[CCode (gir_namespace = "VSGI.HTTP", gir_version = "0.2")]
namespace VSGI.HTTP {

	private errordomain Error {
		FAILED
	}

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

		public override string gateway_interface { owned get { return "HTTP/1.1"; } }

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
		public Request (Connection connection, Message msg, HashTable<string, string>? query) {
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
		 * writing of the status line.
		 */
		protected override bool write_status_line (HTTPVersion http_version, uint status, string reason_phrase, out size_t bytes_written, Cancellable? cancellable = null) {
			bytes_written = 0;
			return true;
		}

		/**
		 * {@inheritDoc}
		 *
		 * Implementation based on {@link Soup.Message} already handles the
		 * writing of the headers.
		 */
		protected override bool write_headers (MessageHeaders headers, out size_t bytes_written, Cancellable? cancellable = null) {
			bytes_written= 0;
			return true;
		}
	}

	/**
	 * @since 0.2
	 */
	public class Connection : VSGI.Connection {

		public Soup.Server soup_server { construct; get; }

		public Message message { construct; get; }

		private InputStream _input_stream;

		public override InputStream input_stream {
			get {
				return this._input_stream;
			}
		}

		private OutputStream _output_stream;

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
		public Connection (Server server, Soup.Server soup_server, Message message) {
			Object (server: server, soup_server: soup_server, message: message);

			this._input_stream  = new MemoryInputStream.from_data (message.request_body.flatten ().data, null);
			this._output_stream = new MessageBodyOutputStream (soup_server, message);

			// prevent the server from completing the message
			soup_server.pause_message (message);
		}
	}

	/**
	 * Implementation of VSGI.Server based on Soup.Server.
	 *
	 * @since 0.1
	 */
	public class Server : VSGI.Server {

		private Soup.Server? server = null;

		private SList<Soup.URI> _uris = new SList<Soup.URI> ();

		public override SList<Soup.URI> uris {
			get {
#if SOUP_2_48
				if (server != null)
					_uris = server.get_uris ();
#endif
				return _uris;
			}
		}

		construct {
#if GIO_2_40
			const OptionEntry[] entries = {
				// port options
				{"port",      'p', 0, OptionArg.INT,  null, "Listen to the provided TCP port", "3003"},
#if SOUP_2_48
				{"all",       'a', 0, OptionArg.NONE, null, "Listen on all interfaces '--port'"},
				{"ipv4-only", '4', 0, OptionArg.NONE, null, "Only listen on IPv4 interfaces"},
				{"ipv6-only", '6', 0, OptionArg.NONE, null, "Only listen on IPv6 interfaces"},

				// fd options
				{"file-descriptor", 'f', 0, OptionArg.INT, null, "Listen to the provided file descriptor"},

				// https options
				{"https",         0, 0, OptionArg.NONE,     null, "Listen for HTTPS connections rather than plain HTTP"},
#endif
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

		public override void listen (Variant options) throws GLib.Error {
			var port          = options.lookup_value ("port", VariantType.INT32) ?? new Variant.@int32 (3003);
			var https         = options.lookup_value ("https", VariantType.BOOLEAN) ?? new Variant.boolean (false);
			var ssl_cert_file = options.lookup_value ("ssl-cert-file", VariantType.BYTESTRING);
			var ssl_key_file  = options.lookup_value ("ssl-key-file", VariantType.BYTESTRING);

			if (server == null) {
				TlsCertificate? tls_certificate = null;
				if (ssl_cert_file != null && ssl_key_file != null) {
					tls_certificate = new TlsCertificate.from_files (options.lookup_value ("ssl-cert-file", VariantType.BYTESTRING).get_bytestring (),
																	 options.lookup_value ("ssl-key-file", VariantType.BYTESTRING).get_bytestring ());
				} else if (https.get_boolean ()) {
					throw new Error.FAILED ("both '--ssl-cert-file' and '--ssl-key-file' must be provided with 'https' option on first 'listen' call");
				}

				if (https.get_boolean ()) {
					this.server = new Soup.Server (
#if !SOUP_2_48
						SERVER_PORT,            port.get_int32 (),
#endif
						SERVER_RAW_PATHS,       options.lookup_value ("raw-paths", VariantType.BOOLEAN) != null,
						SERVER_TLS_CERTIFICATE, tls_certificate);
				} else {
					this.server = new Soup.Server (
#if !SOUP_2_48
						SERVER_PORT,          port.get_int32 (),
#endif
						SERVER_RAW_PATHS,     options.lookup_value ("raw-paths", VariantType.BOOLEAN) != null,
						SERVER_TLS_CERTIFICATE, tls_certificate);
				}

				// register a catch-all handler
				this.server.add_handler (null, (server, msg, path, query, client) => {
					var connection = new Connection (this, server, msg);

					msg.set_status (Status.OK);

					var req = new Request (connection, msg, query);
					var res = new Response (req, msg);

					try {
						dispatch (req, res);
					} catch (GLib.Error err) {
						critical ("%s", err.message);
					}
				});
			} else if (options.lookup_value ("ssl-cert-file", VariantType.BYTESTRING) != null) {
				throw new Error.FAILED ("The 'ssl-cert-file' option can only be set during the first 'listen' call.");
			} else if (options.lookup_value ("ssl-key-file", VariantType.BYTESTRING) != null) {
				throw new Error.FAILED ("The 'ssl-key-file' option can only be set during the first 'listen' call.");
			} else if (options.lookup_value ("raw-paths", VariantType.BOOLEAN) != null) {
				throw new Error.FAILED ("The 'raw-paths' option can only be set during the first 'listen' call.");
			}

			if (options.lookup_value ("server-header", VariantType.STRING) != null)
				this.server.server_header = options.lookup_value ("server-header", VariantType.STRING).get_string ();

#if SOUP_2_48
			ServerListenOptions listen_options = 0;

			if (https.get_boolean ())
				listen_options |= ServerListenOptions.HTTPS;

			if (options.lookup_value ("ipv4-only", VariantType.BOOLEAN) != null)
				listen_options |= ServerListenOptions.IPV4_ONLY;

			if (options.lookup_value ("ipv6-only", VariantType.BOOLEAN) != null)
				listen_options |= ServerListenOptions.IPV6_ONLY;

			if (options.lookup_value ("file-descriptor", VariantType.INT32) != null) {
				this.server.listen_fd (options.lookup_value ("file-descriptor", VariantType.INT32).get_int32 (),
				                       listen_options);
			} else if (options.lookup_value ("all", VariantType.BOOLEAN) != null) {
				this.server.listen_all (port.get_int32 (), listen_options);
			} else {
				this.server.listen_local (port.get_int32 (), listen_options);
			}
#else
			this.server.run_async ();
			_uris.append (new Soup.URI ("%s://0.0.0.0:%u".printf (https.get_boolean () ? "http" : "https", server.port)));
#endif
		}
	}
}
