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

	public errordomain ServerError {
		FAILED
	}

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

		/**
		 * List of URIs this server is currently listening on.
		 *
		 * @since 0.3
		 */
		public abstract SList<Soup.URI> uris { get; }

		/**
		 * Enforces implementation to take the application as a sole argument
		 * and set the {@link GLib.ApplicationFlags.HANDLES_COMMAND_LINE},
		 * {@link GLib.ApplicationFlags.SEND_ENVIRONMENT} and
		 * {@link GLib.ApplicationFlags.NON_UNIQUE} flags.
		 *
		 * @param application served application
		 *
		 * @since 0.2
		 */
		public Server (string application_id, owned ApplicationCallback application) {
			Object (application_id: application_id);
			set_application_callback ((owned) application);
		}

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
			var options = command_line.get_options_dict ();
#else
			var options = new VariantDict ();
#endif

			// keep the process (and workers) alive
			hold ();

			try {
				listen (options);
			} catch (Error err) {
				command_line.printerr ("%s\n", err.message);
				return 1;
			}

			if (options.contains ("forks")) {
				foreach (var uri in uris) {
					command_line.print ("master:\t\tlistening on '%s'\n", uri.to_string (false)[0:-uri.path.length]);
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
							command_line.print ("worker %d:\tlistening on '%s'\n", pid, uri.to_string (false)[0:-uri.path.length]);
						}
					} else {
						command_line.printerr ("could not fork worker: %s (errno %u)\n", strerror (errno), errno);
						return 1;
					}
				}
			} else {
				foreach (var uri in uris) {
					command_line.print ("listening on '%s'\n", uri.to_string (false)[0:-uri.path.length]);
				}
			}

			return 0;
		}

		/**
		 * Prepare the server for listening based on the provided options.
		 *
		 * @param options
		 */
		public abstract void listen (VariantDict options) throws Error;

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
		protected bool dispatch (Request req, Response res) {
			return _application (req, res);
		}
	}
}
