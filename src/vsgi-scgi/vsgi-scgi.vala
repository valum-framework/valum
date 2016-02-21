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

#if INCLUDE_TYPE_MODULE
[ModuleInit]
public Type plugin_init (TypeModule type_module) {
	return typeof (VSGI.SCGI.Server);
}
#endif

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
	public errordomain SCGIError {
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

		private InputStream _body;

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

		public override InputStream body {
			get {
				return _body;
			}
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
	public class Server : VSGI.Server {

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

		/**
		 * @since 0.2.4
		 */
		public SocketService listener { get; protected set; default = new SocketService (); }

		public Server (string application_id, owned VSGI.ApplicationCallback application) {
			base (application_id, (owned) application);
		}

#if GIO_2_40
		construct {
			const OptionEntry[] options = {
				{"any",             'a', 0, OptionArg.NONE, null, "Listen on any open TCP port"},
				{"port",            'p', 0, OptionArg.INT,  null, "Listen to the provided TCP port"},
				{"file-descriptor", 'f', 0, OptionArg.INT,  null, "Listen to the provided file descriptor",       "0"},
				{"backlog",         'b', 0, OptionArg.INT,  null, "Listen queue depth used in the listen() call", "10"},
				{null}
			};

			this.add_main_option_entries (options);
		}
#endif

		public override int command_line (ApplicationCommandLine command_line) {
#if GIO_2_40
			var options  = command_line.get_options_dict ();

			var backlog = options.contains ("backlog") ?
				options.lookup_value ("backlog", VariantType.INT32).get_int32 () : 10;

			listener.set_backlog (backlog);
#endif

			try {
#if GIO_2_40
				if (options.contains ("any")) {
					var port = listener.add_any_inet_port (null);
					command_line.print ("listening on 'scgi://0.0.0.0:%u' (backlog ('%d'))\n", port, backlog);
					command_line.print ("listening on 'scgi://:::%u' (backlog '%d')\n", port, backlog);
				} else if (options.contains ("port")) {
					var port = (uint16) options.lookup_value ("port", VariantType.INT32).get_int32 ();
					listener.add_inet_port (port, null);
					command_line.print ("listening on 'scgi://0.0.0.0:%u' (backlog '%d')\n", port, backlog);
					command_line.print ("listening on 'scgi://:::%u (backlog '%d')'\n", port, backlog);
				} else if (options.contains ("file-descriptor")) {
					var file_descriptor = options.lookup_value ("file-descriptor", VariantType.INT32).get_int32 ();
					listener.add_socket (new Socket.from_fd (file_descriptor), null);
					command_line.print ("listening on file descriptor '%u'\n", file_descriptor);
				} else
#endif
				{
					listener.add_socket (new Socket.from_fd (0), null);
					command_line.print ("listening on the default file descriptor\n");
				}
			} catch (Error err) {
				command_line.print ("%s\n", err.message);
				return 1;
			}

			listener.incoming.connect ((connection) => {
				process_connection.begin (connection, Priority.DEFAULT, null, (obj, result) => {
					try {
						process_connection.end (result);
					} catch (Error err) {
						command_line.printerr ("%s\n", err.message);
						return;
					}
				});
				return false;
			});

			listener.start ();

			// gracefully stop accepting new connections
			shutdown.connect (listener.stop);

			hold ();

			return 0;
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
				if (reader.read_byte () != '\0') {
					throw new SCGIError.MALFORMED_NETSTRING ("missing EOF");
				}

				size_t value_length;
				var @value = reader.read_upto ("", 1, out value_length);
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
	}
}
