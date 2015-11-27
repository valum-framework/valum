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
	 * Produce an artificial EOF when the body has been fully read.
	 */
	public class SCGIInputStream : FilterInputStream {

		public int64 bytes_read = 0;

		public int64 content_length { construct; get; }

		public SCGIInputStream (InputStream base_stream, int64 content_length) {
			Object (base_stream: base_stream, content_length: content_length);
		}

		public override ssize_t read (uint8[] buffer, Cancellable? cancellable = null) throws IOError {
			if (bytes_read >= content_length)
				return 0; // EOF

			if (buffer.length > (content_length - bytes_read)) {
				// the 'int' cast is guarantee since difference is smaller than
				// the buffer length
				buffer.length = (int) (content_length - bytes_read);
			}

			var ret = base_stream.read (buffer, cancellable);

			if (ret > 0)
				bytes_read += ret;

			return ret;
		}

		public override bool close (Cancellable? cancellable = null) throws IOError {
			return base_stream.close (cancellable);
		}
	}

	public class Request : CGI.Request {

		private SCGIInputStream _body;

		public Request (IOStream connection, SCGIInputStream reader, HashTable<string, string> environment) {
			base (connection, environment);

			_body = reader;

			if (environment.contains ("REQUEST_URI"))
				this.uri.set_path (environment["REQUEST_URI"].split ("?", 2)[0]); // avoid the query
		}

		public override InputStream body {
			get {
				return _body;
			}
		}
	}

	public class Response : CGI.Response {

		public Response (Request request) {
			base (request);
		}
	}

	public class Server : VSGI.Server {

		public Server (string application_id, owned VSGI.ApplicationCallback application) {
			base (application_id, (owned) application);

#if GIO_2_40
			const OptionEntry[] options = {
				{"port",            'p', 0, OptionArg.INT, null, "TCP port on this host"},
				{"file-descriptor", 0,   0, OptionArg.INT, null, "listen on a file descriptor", "0"},
				{"backlog",         'b', 0, OptionArg.INT, null, "listen queue depth used in the listen() call", "0"},
				{null}
			};

			this.add_main_option_entries (options);
#endif
		}

		public override int command_line (ApplicationCommandLine command_line) {
			var listener = new SocketService ();

#if GIO_2_40
			var options  = command_line.get_options_dict ();

			if (options.contains ("backlog"))
				listener.set_backlog (options.lookup_value ("backlog", VariantType.INT32).get_int32 ());
#endif

			try {
#if GIO_2_40
				if (options.contains ("port")) {
					var port = (uint16) options.lookup_value ("port", VariantType.INT32).get_int32 ();
					listener.add_inet_port (port, null);
					command_line.print ("listening on tcp://0.0.0.0:%u\n", port);
				} else if (options.contains ("file-descriptor")) {
					var file_descriptor = options.lookup_value ("file-descriptor", VariantType.INT32).get_int32 ();
					listener.add_socket (new Socket.from_fd (file_descriptor), null);
					command_line.print ("listening on file descriptor %u\n", file_descriptor);
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
				// consume the environment from the stream
				var environment = new HashTable<string, string> (str_hash, str_equal);
				var reader      = new DataInputStream (connection.input_stream);

				try {
					size_t length;
					var size = int.parse (reader.read_upto (":", 1, out length));

					// consume the semi-colon
					if (reader.read_byte () != ':') {
						command_line.printerr ("malformed netstring, missing ':'\n");
						return true;
					}

					// consume and extract the environment
					size_t read = 0;
					while (read < size) {
						size_t key_length;
						var key = reader.read_upto ("", 1, out key_length);
						if (reader.read_byte () != '\0') {
							command_line.printerr ("malformed netstring, missing EOF\n");
							return true;
						}

						size_t value_length;
						var @value = reader.read_upto ("", 1, out value_length);
						if (reader.read_byte () != '\0') {
							command_line.printerr ("malformed netstring, missing EOF\n");
							return true;
						}

						read += key_length + 1 + value_length + 1;

						environment[key] = @value;
					}

					assert (read == size);

					// consume the comma following a chunk
					if (reader.read_byte () != ',') {
						command_line.printerr ("malformed netstring, missing ','\n");
						return true;
					}

					var content_length = int.parse (environment["CONTENT_LENGTH"]);

					// buffer the rest of the body
					if (content_length > 0) {
						reader.set_buffer_size (content_length);
						reader.fill (content_length);
					}

					assert (content_length == reader.get_available ());

					var req = new Request (connection, new SCGIInputStream (reader, content_length), environment);
					var res = new Response (req);

					this.handle (req, res);

					debug ("%u %s %s", res.status, req.method, req.uri.path);

				} catch (Error err) {
					command_line.printerr (err.message);
					return true;
				}

				return false;
			});

			listener.start ();

			this.hold ();

			return 0;
		}
	}
}
