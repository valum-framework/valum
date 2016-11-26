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
 */
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
	private class Request : VSGI.Request {

		/**
		 * Message underlying this request.
		 */
		public Message message { construct; get; }

		/**
		 * {@inheritDoc}
		 *
		 * @param connection contains the connection obtain from
		 *                   {@link Soup.ClientContext.steal_connection} or a
		 *                   stud if it is not available
		 * @param msg        message underlying this request
		 * @param query      parsed HTTP query provided by {@link Soup.ServerCallback}
		 */
		public Request (Connection connection, Message msg, HashTable<string, string>? query) {
			Object (connection:        connection,
			        message:           msg,
			        http_version:      msg.http_version,
			        gateway_interface: "HTTP/1.1",
			        method:            msg.method,
			        uri:               msg.uri,
			        query:             query,
			        headers:           msg.request_headers);
		}
	}

	/**
	 * Soup Response
	 */
	private class Response : VSGI.Response {

		/**
		 * Message underlying this response.
		 */
		public Message message { construct; get; }

		public override uint status {
			get { return this.message.status_code; }
			set { this.message.status_code = value; }
		}

		public override string? reason_phrase {
			owned get { return this.message.reason_phrase == "Unknown Error" ? null : this.message.reason_phrase; }
			set { this.message.reason_phrase = value ?? Status.get_phrase (this.message.status_code); }
		}

		/**
		 * {@inheritDoc}
		 *
		 * @param msg message underlying this response
		 */
		public Response (Request req, Message msg) {
			Object (request: req, message: msg, headers: msg.response_headers);
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

	private class Connection : IOStream {

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
		public Connection (Soup.Server soup_server, Message message) {
			Object (soup_server: soup_server, message: message);

			this._input_stream  = new MemoryInputStream.from_data (message.request_body.flatten ().data, null);
			this._output_stream = new MessageBodyOutputStream (soup_server, message);

			// prevent the server from completing the message
			soup_server.pause_message (message);
		}
	}

	/**
	 * Implementation of VSGI.Server based on Soup.Server.
	 */
	[Version (since = "0.1")]
	public class Server : VSGI.Server, Initable {

#if !SOUP_2_48
		[Version (since = "0.3")]
		[Description (blurb = "The port the server is listening on")]
		public Address @interface { construct; get; default = new Address.any (AddressFamily.IPV4, 3003); }
#endif

		[Version (since = "0.3")]
		[Description (blurb = "Listen for HTTPS connections rather than plain HTTP")]
		public bool https { construct; get; default = false; }

		[Version (since = "0.3")]
		[Description (blurb = "TLS certificate containing both a PEM-Encoded certificate and private key")]
		public TlsCertificate? tls_certificate { construct; get; default = null; }

		[Version (since = "0.3")]
		[Description (blurb = "Value to use for the 'Server' header on Messages processed by this server")]
		public string? server_header { construct; get; default = null; }

		[Version (since = "0.3")]
		[Description (blurb = "Percent-encoding in the Request-URI path will not be automatically decoded")]
		public bool raw_paths { construct; get; default = false; }

		public override SList<URI> uris {
			owned get {
#if SOUP_2_48
				return server.get_uris ();
#else
				var _uris = new SList<Soup.URI> ();

				_uris.append (new Soup.URI ("%s://%s:%d/".printf (https ? "https" : "http",
				                                                  @interface.physical,
				                                                  @interface.port)));

				return _uris;
#endif
			}
		}

		private Soup.Server server;

#if SOUP_2_48
		private ServerListenOptions server_listen_options = 0;
#endif

#if !SOUP_2_48
		construct {
			if (@interface == null) {
				@interface = new Address.any (AddressFamily.IPV4, 3003);
			}
		}
#endif

		public bool init (Cancellable? cancellable = null) throws GLib.Error {
			if (https) {
				server = new Soup.Server (
#if !SOUP_2_48
					SERVER_INTERFACE,       @interface,
#endif
					SERVER_RAW_PATHS,       raw_paths,
					SERVER_TLS_CERTIFICATE, tls_certificate);
			} else {
				server = new Soup.Server (
#if !SOUP_2_48
					SERVER_INTERFACE,       @interface,
#endif
					SERVER_RAW_PATHS,       raw_paths,
					SERVER_TLS_CERTIFICATE, tls_certificate);
			}

			// register a catch-all handler
			server.add_handler (null, (server, msg, path, query, client) => {
				var connection = new Connection (server, msg);

				msg.set_status (Status.OK);

				var req = new Request (connection, msg, query);
				var res = new Response (req, msg);

				var auth = req.headers.get_one ("Authorization");
				if (auth != null) {
					if (str_case_equal (auth.slice (0, 6), "Basic ")) {
						var auth_data = (string) Base64.decode (auth.substring (6));
						if (auth_data.index_of_char (':') != -1) {
							req.uri.set_user (auth_data.slice (0, auth.index_of_char (':')));
						}
					} else if (str_case_equal (auth.slice (0, 7), "Digest ")) {
						var auth_data = header_parse_param_list (auth.substring (7));
						req.uri.set_user (auth_data["username"]);
					}
				}

				dispatch_async.begin (req, res, Priority.DEFAULT, (obj, result) => {
					try {
						dispatch_async.end (result);
					} catch (Error err) {
						critical ("%s", err.message);
					}
				});
			});

			if (server_header != null)
				server.server_header = server_header;

#if SOUP_2_48
			if (https)
				server_listen_options |= ServerListenOptions.HTTPS;
#else
			server.run_async ();
#endif

			return true;
		}

		public override void listen (SocketAddress? address = null) throws GLib.Error {
#if SOUP_2_48
			if (address == null) {
				server.listen_local (3003, server_listen_options);
			} else {
				server.listen (address, server_listen_options);
			}
#else
			if (address != null) {
				throw new IOError.NOT_SUPPORTED ("Prior to libsoup-2.4 (>=2.48), this implementation is only listening via the 'interface' property.");
			}
#endif
		}

		public override void listen_socket (GLib.Socket socket) throws GLib.Error {
#if SOUP_2_48
			server.listen_socket (socket, server_listen_options);
#else
			throw new IOError.NOT_SUPPORTED ("Prior to libsoup-2.4 (>=2.48), this implementation is only listening via the 'interface' property.");
#endif
		}

		public override void stop () {
#if SOUP_2_48
			server.disconnect ();
#else
			server.quit ();
#endif
		}
	}
}
