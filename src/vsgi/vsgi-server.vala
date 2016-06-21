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

namespace VSGI {

	/**
	 * Server that feeds a {@link VSGI.ApplicationCallback} with incoming
	 * requests.
	 *
	 * Once you have initialized a Server instance, start it by calling
	 * {@link GLib.Application.run} with the command-line arguments or a set of
	 * predefined arguments.
	 *
	 * The server should be implemented by overriding the
	 * {@link GLib.Application.command_line} signal.
	 *
	 * @since 0.1
	 */
	public abstract class Server : GLib.Application {

		private static HashTable<string, ServerModule>? _server_modules = null;

		/**
		 * Instantiate a new {@link VSGI.Server} instance.
		 *
		 * If the 'VSGI_SERVER_PATH' environment variable is set, it will used
		 * instead of the default system path.
		 *
		 * For a more fine-grained control, use {@link VSGI.ServerModule}.
		 *
		 * @since 0.3
		 *
		 * @param name name of the server implementation to load
		 *
		 * @return the server instance of loaded successfully, otherwise 'null'
		 *         and a warning will be emitted
		 */
		public static new Server? @new (string name, ...) {
			if (_server_modules == null)
				_server_modules = new HashTable<string, ServerModule> (str_hash, str_equal);
			if (_server_modules[name] == null) {
				var server_module = new ServerModule (Environment.get_variable ("VSGI_SERVER_PATH"), name);
				if (!server_module.load ())
					return null;
				_server_modules[name] = server_module;
			}
			return Object.@new_valist (_server_modules[name].server_type, null, va_list ()) as Server;
		}

		/**
		 * Instantiate a new {@link VSGI.Server} with an initial application
		 * callback.
		 *
		 * @since 0.3
		 *
		 * @param application_id application identifier, it must be a valid
		 *                       {@link GLib.Application} identifier
		 * @param application    application callback
		 *
		 * @return the server instance of loaded successfully, otherwise 'null'
		 *         and a warning will be emitted
		 */
		public static Server? new_with_application (string name, string application_id, owned ApplicationCallback callback) {
			var server = @new (name, "application-id", application_id);
			if (server != null) {
				server.set_application_callback ((owned) callback);
			}
			return server;
		}

		/**
		 * List of URIs this server is currently listening on.
		 *
		 * @since 0.3
		 */
		public abstract SList<Soup.URI> uris { get; }

		private ApplicationCallback _application;

		/**
		 * Assign the callback used when {@link VSGI.Server.dispatch} is called.
		 */
		public void set_application_callback (owned ApplicationCallback application) {
			_application = (owned) application;
		}

		construct {
			flags |= ApplicationFlags.HANDLES_COMMAND_LINE |
			         ApplicationFlags.SEND_ENVIRONMENT |
			         ApplicationFlags.NON_UNIQUE;
#if GIO_2_40
			const OptionEntry[] entries = {
				// general options
				{"forks", 0, 0, OptionArg.INT, null, "Number of fork to create", "0"},
				{null}
			};
			this.add_main_option_entries (entries);
#endif
		}

		public override int command_line (ApplicationCommandLine command_line) {
#if GIO_2_40
			var options = command_line.get_options_dict ().end ();
#else
			var options = new Variant ("a{sv}");
#endif

			try {
				listen (options);
			} catch (Error err) {
				command_line.printerr ("%s\n", err.message);
				return 1;
			}

			if (options.lookup_value ("forks", VariantType.INT32) != null) {
				foreach (var uri in uris) {
					command_line.printerr ("master:\t\tlistening on '%s'\n", uri.to_string (false)[0:-uri.path.length]);
				}
				var remaining = options.lookup_value ("forks", VariantType.INT32).get_int32 ();
				for (var i = 0; i < remaining; i++) {
					var pid = fork ();
					if (pid == 0) {
						return 0;
					} else if (pid > 0) {
						ChildWatch.add (pid, (pid, status) => {
							command_line.print ("worker %d:\texited with status '%d'\n", pid, status);
						});
						foreach (var uri in uris) {
							command_line.printerr ("worker %d:\tlistening on '%s'\n", pid, uri.to_string (false)[0:-uri.path.length]);
						}
					} else {
						command_line.printerr ("could not fork worker: %s (errno %u)\n", strerror (errno), errno);
						return 1;
					}
				}
			} else {
				foreach (var uri in uris) {
					command_line.printerr ("listening on '%s'\n", uri.to_string (false)[0:-uri.path.length]);
				}
			}

			// keep the process (and workers) alive
			hold ();

			return 0;
		}

		/**
		 * Prepare the server for listening based on the provided options.
		 *
		 * @param options dictionary of options that map string to variant, just
		 *                like {@link GLib.ApplicationCommandLine}
		 *
		 * @throws Error if anything fail during the initialization, use
		 *               {@link VSGI.ServerError} for general errors
		 */
		public abstract void listen (Variant options) throws Error;

		/**
		 * Fork the execution.
		 *
		 * This is called after {@link VSGI.Server.listen} such that workers can
		 * share listening interfaces and descriptors.
		 *
		 * The default implementation invoke {@link Posix.fork}.
		 *
		 * To disable forking, simply override this and return '0'.
		 *
		 * @since 0.3
		 */
		public virtual Pid fork () {
			return Posix.fork ();
		}

		/**
		 * Dispatch the request to the application callback.
		 *
		 * The application must call {@link Response.write_head} at some point.
		 *
		 * Once dispatched, the {@link Response.head_written} property is
		 * expected to be true unless its reference still held somewhere else
		 * and the return value is 'true'.
		 *
		 * @return true if the request and response were dispatched
		 */
		protected bool dispatch (Request req, Response res) throws Error {
			return _application (req, res);
		}
	}
}
