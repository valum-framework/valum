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

[ModuleInit]
public Type server_init (TypeModule type_module) {
	return typeof (VSGI.Ajp.Server);
}

/**
 * Implementation of the Apache JServ Protocol.
 *
 * [[https://tomcat.apache.org/connectors-doc/ajp/ajpv13a.html]]
 */
namespace VSGI.Ajp {

	private errordomain Error {
		BAD_COMMON_REQUEST_HEADER
	}

	private enum PacketType {
		FORWARD_REQUEST = 0x02,
		SEND_BODY_CHUNK = 0x03,
		SEND_HEADERS    = 0x04,
		END_RESPONSE    = 0x05,
		GET_BODY_CHUNK  = 0x06,
		SHUTDOWN        = 0x07,
		PING            = 0x08,
		CPONG           = 0x09,
		CPING           = 0x0A
	}

	private enum Method {
		OPTIONS          = 0x01,
		GET              = 0x02,
		HEAD             = 0x03,
		POST             = 0x04,
		PUT              = 0x05,
		DELETE           = 0x06,
		TRACE            = 0x07,
		PROPFIND         = 0x08,
		PROPPATCH        = 0x09,
		MKCOL            = 0x0A,
		COPY             = 0x0B,
		MOVE             = 0x0C,
		LOCK             = 0x0D,
		UNLOCK           = 0x0E,
		ACL              = 0x0F,
		REPORT           = 0x10,
		VERSION_CONTROL  = 0x11,
		CHECKIN          = 0x12,
		CHECKOUT         = 0x13,
		UNCHECKOUT       = 0x14,
		SEARCH           = 0x15,
		MKWORKSPACE      = 0x16,
		UPDATE           = 0x17,
		LABEL            = 0x18,
		MERGE            = 0x19,
		BASELINE_CONTROL = 0x1A,
		MKACTIVITY       = 0x1B
	}

	private const string[] COMMON_REQUEST_HEADERS = {
		"accept",
		"accept-charset",
		"accept-encoding",
		"accept-language",
		"authorization",
		"connection",
		"content-type",
		"content-length",
		"cookie",
		"cookie2",
		"host",
		"pragma",
		"referer",
		"user-agent"
	};

	private const string[] COMMON_RESPONSE_HEADERS = {
		"content-type",
		"content-language",
		"content-length",
		"date",
		"last-modified",
		"location",
		"set-cookie",
		"set-cookie2",
		"servlet-engine",
		"status",
		"www-authenticate"
	};

	private enum Attribute {
		CONTEXT       = 0x01,
		SERVLET_PATH  = 0x02,
		REMOTE_USER   = 0x03,
		AUTH_TYPE     = 0x04,
		QUERY_STRING  = 0x05,
		ROUTE         = 0x06,
		SSL_CERT      = 0x07,
		SSL_CIPHER    = 0x08,
		SSL_SESSION   = 0x09,
		REQ_ATTRIBUTE = 0x0A,
		SSL_KEY_SIZE  = 0x0B,
		SECRET        = 0x0C,
		STORED_METHOD = 0x0D,
		ARE_DONE      = 0xFF
	}

	/**
	 * Filter a base stream to consume body chunks.
	 */
	private class ChunkInputStream : FilterInputStream {

		/**
		 * Tells if the first chunk was read.
		 */
		private bool _first_chunk_read = false;

		/**
		 * Number of bytes remaining to read in the current chunk.
		 */
		private size_t _remaining_in_chunk = 0;

		public DataOutputStream output_stream { construct; get; }

		public ChunkInputStream (InputStream base_stream, DataOutputStream output_stream) {
			Object (base_stream: base_stream, output_stream: output_stream);
		}

		/**
		 *
		 */
		public override ssize_t read (uint8[] buffer, Cancellable? cancellable = null) throws GLib.IOError {
			buffer.length = buffer.length % uint16.MAX;

			if (_first_chunk_read && _remaining_in_chunk == 0) {
				// request more bytes
				output_stream.put_byte ('A');
				output_stream.put_byte ('B');
				output_stream.put_uint16 (3);
				output_stream.put_byte (PacketType.GET_BODY_CHUNK);
				output_stream.put_uint16 ((uint16) buffer.length);
				output_stream.flush ();
			}

			uint8 b[4];
			base_stream.read_all (b, null);
			assert (b[0] == 0x12);
			assert (b[1] == 0x34);
			_first_chunk_read   = true;
			_remaining_in_chunk = b[3] << 8 + b[4];

			message ("%lu", _remaining_in_chunk);

			buffer.length = (int) size_t.min ((size_t) buffer.length, _remaining_in_chunk);

			var bytes_read = base_stream.read (buffer, cancellable);

			_remaining_in_chunk -= bytes_read;

			return bytes_read;
		}

		public override bool close (Cancellable? cancellable = null) {
			return base_stream.close ();
		}
	}

	/**
	 * Filter a base stream to send body chunks.
	 */
	private class ChunkOutputStream : FilterOutputStream {

		public ChunkOutputStream (OutputStream base_stream) {
			Object (base_stream: base_stream);
		}

		/**
		 * Remaining bytes to write in the current chunk.
		 */
		private size_t _remaining_in_chunk = 0;

		public override ssize_t write (uint8[] buffer, Cancellable? cancellable = null) throws GLib.IOError {
			if (_remaining_in_chunk == 0) {
				base_stream.write_all ({'A', 'B', PacketType.SEND_BODY_CHUNK, (uint8) buffer.length >> 8, (uint8) buffer.length},
				null);
				_remaining_in_chunk = buffer.length;
			}

			var bytes_written = base_stream.write (buffer[0:_remaining_in_chunk], cancellable);

			_remaining_in_chunk -= bytes_written;

			return bytes_written;
		}

		/**
		 * Write a {@link PacketType.END_RESPONSE} packet to indicate that this
		 * request has ended.
		 *
		 * The {@link FilterOutputStream.close_base_stream} property is used to
		 * determine if the connection can be reused.
		 */
		public override bool close (Cancellable? cancellable = null) throws GLib.IOError {
			size_t bytes_written;
			return base_stream.write_all ({'A', 'B', 2, PacketType.END_RESPONSE, 0x01}, out bytes_written) &&
			       base_stream.close ();
		}
	}

	private class Response : VSGI.Response {

		private DataOutputStream @out;

		public Response (Request request, ChunkOutputStream body) {
			base (request, Soup.Status.OK, null, body);
		}

		construct {
			@out = new DataOutputStream (request.connection.output_stream);
		}

		private Soup.HTTPVersion _stored_http_version;
		private uint             _stored_status;
		private string           _stored_reason_phrase;

		/**
		 * Build a 'SEND_HEADERS' packet.
		 */
		protected override bool write_status_line (Soup.HTTPVersion http_version,
		                                           uint             status,
		                                           string           reason_phrase,
		                                           out size_t       bytes_written,
		                                           Cancellable?     cancellable = null) throws GLib.IOError {
			_stored_http_version  = http_version;
			_stored_status        = status;
			_stored_reason_phrase = reason_phrase;

			bytes_written = 0;
			return true;
		}

		protected override bool write_headers (Soup.MessageHeaders headers,
		                                       out size_t          bytes_written,
		                                       Cancellable?        cancellable = null) throws GLib.IOError {
			@out.put_byte ('A');
			@out.put_byte ('B');
			@out.put_byte (PacketType.SEND_HEADERS);

			var packet_len = 3 + 2 + _stored_reason_phrase.length + 1;
			var num_headers = 0;
			headers.foreach ((n, h) => {
				packet_len += (uint16) n.length + 1;
				packet_len += (uint16) h.length + 1;
				num_headers++;
			});

			@out.put_uint16 (packet_len);

			@out.put_uint16 ((uint16) _stored_status);
			@out.put_uint16 ((uint16) _stored_reason_phrase.length + 1);
			@out.put_string (_stored_reason_phrase);

			// room for 'num_headers'
			@out.put_uint16 (num_headers);

			// register common headers
			for (var i = 0; i < COMMON_RESPONSE_HEADERS.length; i++) {
				var header = COMMON_RESPONSE_HEADERS[i].has_prefix ("set-cookie") ? headers.get_list (COMMON_RESPONSE_HEADERS[i]) :
				                                                                   headers.get_one (COMMON_RESPONSE_HEADERS[i]);
				if (header == null)
					continue;
				@out.put_byte (0x0A);
				@out.put_byte (i + 1);
				@out.put_uint16 ((uint16) header.length);
				@out.put_string (header);
			}

			Soup.MessageHeadersIter headers_iter;
			Soup.MessageHeadersIter.init (out headers_iter, headers);
			string name;
			string header;
			while (headers_iter.next (out name, out header)) {
				// skip common headers
				if (strv_contains (COMMON_RESPONSE_HEADERS, name.down ()))
					continue;
				@out.put_uint16 ((uint16) name.length + 1);
				@out.put_string (name);
				@out.put_uint16 ((uint16) header.length + 1);
				@out.put_string (header);
			}

			bytes_written = 3 + packet_len;

			@out.flush ();

			return true;
		}
	}

	[Version (since = "0.4")]
	public class Server : SocketServer {

		protected override string scheme { get { return "ajp"; } }

		protected override bool incoming (SocketConnection connection) {
			process_connection.begin (connection, (obj, result) => {
				try {
					process_connection.end (result);
				} catch (GLib.Error err) {
					critical ("%s", err.message);
				}
			});
			return false;
		}

		private static bool read_bool (DataInputStream @in) throws GLib.Error {
			return @in.read_byte () == 1;
		}

		private static string? read_string (DataInputStream @in) throws GLib.Error {
			var len = @in.read_uint16 ();
			if (len == uint16.MAX) {
				return null;
			}
			var buffer = new uint8[len + 1];
			@in.read_all (buffer, null, null);
			return (string) buffer;
		}

		private async void process_connection (SocketConnection connection) throws GLib.Error {
			var @in  = new DataInputStream (connection.input_stream);
			var @out = new DataOutputStream (connection.output_stream);

			var packet_magic = @in.read_uint16 () != 0x1234;
			var packet_len   = @in.read_uint16 ();
			yield @in.fill_async (packet_len);

			switch (@in.read_byte ()) {
				case PacketType.FORWARD_REQUEST:
					var method = ((EnumClass) typeof (Method).class_ref ())
					.get_value (@in.read_byte ())
					.value_nick
					.up ();

					var protocol = read_string (@in);

					var http_version = protocol == "HTTP/1.0" ? Soup.HTTPVersion.@1_0 : Soup.HTTPVersion.@1_1;

					var req_uri = read_string (@in);

					var remote_addr = read_string (@in);  // 'remote_addr'
					var remote_host = read_string (@in);  // 'remote_host'
					var server_name = read_string (@in);  // 'server_name'
					var server_port = @in.read_uint16 (); // 'server_port'

					var uri = new Soup.URI ("http://%s:%u%s".printf (server_name, server_port, req_uri));

					// 'is_ssl'
					if (read_bool (@in))
						uri.set_scheme ("https");

					var headers = new Soup.MessageHeaders (Soup.MessageHeadersType.REQUEST);
					var num_headers = @in.read_uint16 ();
					for (int i = 0; i < num_headers; i++) {
						string name;
						var name_len = @in.read_uint16 ();
						if ((name_len >> 8) == 0xA0) {
							if (likely (0x01 <= (name_len & 0x00FF) <= 0x0E)) {
								name = COMMON_REQUEST_HEADERS[(name_len & 0x00FF) - 1];
							} else {
								throw new Error.BAD_COMMON_REQUEST_HEADER ("");
							}
						} else {
							var name_buf = new uint8[name_len + 1];
							@in.read_all (name_buf, null);
							name = (string) name_buf;
						}
						var header = read_string (@in);
						headers.append (name, header);
					}

					// attributes
					uint8 attribute = 0;
					while (true) {
						attribute = @in.read_byte ();
						if (attribute == Attribute.ARE_DONE) {
							break;
						}
						switch (attribute) {
							case Attribute.REMOTE_USER: // 'remote_user'
								uri.set_user (read_string (@in));
								break;
							case Attribute.QUERY_STRING: // 'query_string'
								uri.set_query (read_string (@in));
								break;
							case Attribute.REQ_ATTRIBUTE:
								read_string (@in); // name
								read_string (@in); // value
								break;
							default:
								read_string (@in);
								break;
						}
					}

					var content_length = headers.get_content_length ();

					var req = new Request (connection,
					                       method,
					                       uri,
					                       null,
					                       http_version,
					                       headers,
					                       new BoundedInputStream (new ChunkInputStream (@in, @out), content_length));
					var res = new Response (req, new ChunkOutputStream (@out));

					yield handler.handle_async (req, res);
					break;
				case PacketType.SHUTDOWN:
					if (connection.get_remote_address ().get_family () == SocketFamily.UNIX ||
						(connection.get_remote_address () as InetAddress).get_is_loopback ()) {
						stop ();
					} else {
						warning ("Shutdown attempt from a non-local client: '%s'.", connection.get_remote_address ().to_string ());
					}
					break;
				case PacketType.PING:
					break;
				case PacketType.CPING:
					try {
						@out.put_byte ('A');
						@out.put_byte ('B');
						@out.put_uint16 (1);
						@out.put_byte (PacketType.CPONG);
						yield @out.flush_async ();
					} catch (GLib.IOError err) {
						critical ("Could not reply 'CPONG' to a 'CPING' request.");
					}
					break;
				default:
					critical ("Unknown packet type.");
					break;
			}

			yield connection.close_async ();
		}
	}
}
