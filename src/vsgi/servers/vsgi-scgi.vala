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
	return typeof (VSGI.SCGI.Server);
}

/**
 * SCGI implementation of VSGI.
 *
 * This implementation takes a maximum advantage of non-blocking I/O as it is
 * fully implemented with GIO APIs.
 *
 * The request InputStream is initially consumed as a netstring to extract the
 * environment variables using a {@link GLib.DataInputStream}. The resulting
 * stream is then exposed as the request body.
 *
 * @since 0.2
 */
[CCode (gir_namespace = "VSGI.SCGI", gir_version = "0.2")]
namespace VSGI.SCGI {

	/**
	 * @since 0.3
	 */
	private errordomain SCGIError {
		/**
		 *
		 */
		FAILED,
		/**
		 * The submitted netstring is not well formed.
		 *
		 * @since 0.3
		 */
		MALFORMED_NETSTRING,
		/**
		 * @since 0.3
		 */
		MISSING_CONTENT_LENGTH,
		/**
		 * @since 0.3
		 */
		BAD_CONTENT_LENGTH
	}

	/**
	 * {@inheritDoc}
	 *
	 * The connection {@link GLib.InputStream} is ignored as it is being
	 * typically consumed for its netstring. This is why the constructor
	 * expects a separate body stream.
	 */
	public class Request : CGI.Request {

		/**
		 * {@inheritDoc}
		 *
		 * @since 2.3.3
		 *
		 * @param reader stream holding the request body
		 */
		public Request (IOStream connection, InputStream reader, string[] environment) {
			base (connection, environment);
			_body = reader;
		}
	}

	/**
	 * {@inheritDoc}
	 */
	public class Response : CGI.Response {

		public Response (Request request) {
			base (request);
		}
	}

	/**
	 * {@inheritDoc}
	 */
	public class Server : VSGI.SocketListenerServer {

		protected override string protocol { get { return "scgi"; } }

		protected override bool handle_incoming_socket_connection (SocketConnection connection, Object? obj) {
			process_connection.begin (connection, Priority.DEFAULT, null, (obj, result) => {
				try {
					process_connection.end (result);
				} catch (Error err) {
					critical ("%s", err.message);
				}
			});
			return false;
		}

		private async void process_connection (SocketConnection connection,
		                                       int priority = GLib.Priority.DEFAULT,
		                                       Cancellable? cancellable = null) throws Error {
			// consume the environment from the stream
			string[] environment = {};
			var reader           = new DataInputStream (connection.input_stream);

			// buffer the request
			yield reader.fill_async (-1, priority, cancellable);

			size_t length;
			var size_str = reader.read_upto (":", 1, out length);

			if (size_str == null) {
				throw new SCGIError.FAILED ("could not read netstring length");
			}

			int64 size;
			if (!int64.try_parse (size_str, out size)) {
				throw new SCGIError.MALFORMED_NETSTRING ("'%s' is not a valid netstring length", size_str);
			}

			// consume the semi-colon
			if (reader.read_byte () != ':') {
				throw new SCGIError.MALFORMED_NETSTRING ("missing ':'");
			}

			// consume and extract the environment
			size_t read = 0;
			while (read < size) {
				size_t key_length;
				var key = reader.read_upto ("", 1, out key_length);
				if (key == null) {
					throw new SCGIError.FAILED ("could not read key");
				}
				if (reader.read_byte () != '\0') {
					throw new SCGIError.MALFORMED_NETSTRING ("missing EOF");
				}

				size_t value_length;
				var @value = reader.read_upto ("", 1, out value_length);
				if (@value == null) {
					throw new SCGIError.FAILED ("could not read value for key '%s'", key);
				}
				if (reader.read_byte () != '\0') {
					throw new SCGIError.MALFORMED_NETSTRING ("missing EOF");
				}

				read += key_length + 1 + value_length + 1;

				environment = Environ.set_variable (environment, key, @value);
			}

			assert (read == size);

			// consume the comma following a chunk
			if (reader.read_byte () != ',') {
				throw new SCGIError.MALFORMED_NETSTRING ("missing ','");
			}

			var content_length_str = Environ.get_variable (environment, "CONTENT_LENGTH");

			if (content_length_str == null) {
				throw new SCGIError.MISSING_CONTENT_LENGTH ("the content length is a mandatory field");
			}

			int64 content_length;
			if (!int64.try_parse (content_length_str, out content_length)) {
				throw new SCGIError.BAD_CONTENT_LENGTH ("'%s' is not a valid content length", content_length_str);
			}

			// buffer the rest of the body
			if (content_length > 0) {
				if (sizeof (size_t) < sizeof (int64) && content_length > size_t.MAX) {
					throw new SCGIError.FAILED ("request body is too big (%sB) to be held in a buffer",
					                            content_length.to_string ());
				}

				// resize the buffer onlf if needed
				if (content_length > reader.buffer_size)
					reader.set_buffer_size ((size_t) content_length);

				// fill the buffer if needed
				if (reader.get_available () < content_length) {
					yield reader.fill_async ((ssize_t) content_length - (ssize_t) reader.get_available (), priority, cancellable);
				}

				if (content_length < reader.get_available ()) {
					throw new SCGIError.FAILED ("request body (%sB) could not be buffered",
					                            content_length.to_string ());
				}
			}

			var req = new Request (new Connection (connection), new BoundedInputStream (reader, content_length), environment);
			var res = new Response (req);

			dispatch (req, res);
		}

		/**
		 * Provide an auto-closing SCGI connection.
		 */
		private class Connection : IOStream {

			/**
			 *
			 */
			public IOStream base_connection { construct; get; }

			public override InputStream input_stream {
				get {
					return base_connection.input_stream;
				}
			}

			public override OutputStream output_stream {
				get {
					return base_connection.output_stream;
				}
			}

			public Connection (IOStream base_connection) {
				Object (base_connection: base_connection);
			}

			~Connection ()  {
				base_connection.close ();
			}
		}
	}
}
