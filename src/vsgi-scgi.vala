/**
 * SCGI implementation of VSGI.
 *
 * This implementation takes a maximum advantage of non-blocking I/O as it is
 * fully implemented with GIO APIs.
 *
 * The request InputStream is initially consumed as a netstring to extract the
 * environment variables.
 *
 * @since 0.2
 */
[CCode (gir_namespace = "VSGI.SCGI", gir_version = "0.2")]
namespace VSGI.SCGI {

	public class Request : CGI.Request {

		public Request (IOStream connection, HashTable<string, string> environment) {
			base (connection, environment);

			if (environment.contains ("REQUEST_URI"))
				this.uri.set_path (environment["REQUEST_URI"].split ("?", 2)[0]); // avoid the query
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
					var port = options.lookup_value ("port", VariantType.INT32).get_int16 ();
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
					var size   = int.parse (reader.read_upto (":", 1, out length));

					// consume the semi-colon
					if (reader.read_byte () != ':') {
						command_line.printerr ("malformed netstring, missing ':'\n");
						return true;
					}

					// consume and extract the environment
					string? last_key = null;
					size_t last_length;
					size_t read = 0;
					while (read < size) {
						if (last_key == null) {
							last_key = reader.read_upto ("", 1, out last_length);
						} else {
							environment[last_key] = reader.read_upto ("", 1, out last_length);
							last_key = null;
						}
						if (reader.read_byte () != '\0') {
							command_line.printerr ("malformed netstring, missing EOF\n");
							return true;
						}
						read += 1 + last_length;
					}

					assert (read == size);

					// consume the comma following a chunk
					if (reader.read_byte () != ',') {
						command_line.printerr ("malformed netstring, missing ','\n");
						return true;
					}
				} catch (IOError err) {
					command_line.printerr (err.message);
					return true;
				}

				var req = new Request (connection, environment);
				var res = new Response (req);

				this.handle (req, res);

				debug ("%u %s %s", res.status, req.method, req.uri.path);

				return false;
			});

			listener.start ();

			this.hold ();

			return 0;
		}
	}
}
