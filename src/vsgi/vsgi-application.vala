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
 * @since 0.3
 */
public class VSGI.Application : GLib.Application {

	/**
	 * @since 0.3
	 */
	public Server server { get; construct; }

	/**
	 * @since 0.3
	 */
	public Application (Server server) {
		Object (server: server);
	}

	construct {
		flags |= ApplicationFlags.HANDLES_COMMAND_LINE |
		         ApplicationFlags.SEND_ENVIRONMENT     |
		         ApplicationFlags.NON_UNIQUE;
#if GIO_2_40
		const OptionEntry[] entries = {
			// general options
			{"forks", 0, 0, OptionArg.INT, null, "Number of fork to create", "0"},
			{null}
		};
		add_main_option_entries (entries);
		if (server.get_listen_options ().length > 0)
			add_main_option_entries (server.get_listen_options ());
#endif
	}

	public override int command_line (ApplicationCommandLine command_line) {
#if GIO_2_40
		var options = command_line.get_options_dict ().end ();
#else
		var options = new Variant ("a{sv}");
#endif

		// per-worker logging
		if (Posix.isatty (stderr.fileno ())) {
			Log.set_handler (null, LogLevelFlags.LEVEL_MASK, (domain, level, message) => {
				stderr.printf ("[%s] %s%s:%s %s%s%s%s\n",
				               new DateTime.now_utc ().format ("%FT%H:%M:%S.000Z"),
				               "\x1b[33m",
				               "worker %d".printf (Posix.getpid ()),
				               "\x1b[0m",
				               domain == null ? "" : "%s: ".printf (domain),
				               LogLevelFlags.LEVEL_ERROR    in level ? "\x1b[31m" :
				               LogLevelFlags.LEVEL_CRITICAL in level ? "\x1b[31m" :
				               LogLevelFlags.LEVEL_WARNING  in level ? "\x1b[33m" :
				               LogLevelFlags.LEVEL_MESSAGE  in level ? "\x1b[32m" :
#if GLIB_2_40
				               LogLevelFlags.LEVEL_INFO     in level ? "\x1b[34m" :
#endif
				               LogLevelFlags.LEVEL_DEBUG    in level ? "\x1b[36m" : "",
				               message.replace ("\n", "\n\t\t"),
				               "\x1b[0m");
			});
		} else {
			Log.set_handler (null, LogLevelFlags.LEVEL_MASK, (domain, level, message) => {
				Log.default_handler (domain, level, "[%s] %s".printf (new DateTime.now_utc ().format ("%FT%H:%M:%S.000Z"), message));
			});
		}

		try {
			server.listen (options);
		} catch (Error err) {
			critical ("%s (%s, %d)", err.message, err.domain.to_string (), err.code);
			return 1;
		}

		if (options.lookup_value ("forks", VariantType.INT32) != null) {
			var forks = options.lookup_value ("forks", VariantType.INT32).get_int32 ();
			try {
				for (var i = 0; i < forks; i++) {
					var pid = server.fork ();

					// worker
					if (pid == 0) {
						break;
					}

					// parent
					else {
						// monitor child process
						ChildWatch.add (pid, (pid, status) => {
							warning ("worker %d exited with status '%d'", pid, status);
						});
					}
				}
			} catch (Error err) {
				critical ("%s (%s, %d)", err.message, err.domain.to_string (), err.code);
				return 1;
			}
		}

		foreach (var uri in server.uris) {
			message ("listening on '%s'", uri.to_string (false)[0:-uri.path.length]);
		}

		// keep the process (and workers) alive
		hold ();

		// release on 'SIGTERM'
		Unix.signal_add (ProcessSignal.TERM, () => {
			release ();
			server.stop ();
			return false;
		}, Priority.LOW);

		return 0;
	}
}
