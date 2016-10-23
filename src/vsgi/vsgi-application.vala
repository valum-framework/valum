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
 * Cushion around {@link VSGI.Server}.
 *
 * It automatically parses the CLI arguments into {@link VSGI.Server.listen}
 * calls, produces pretty logs, run a {@link GLib.MainLoop} and gracefully
 * shutdown if a 'SIGTERM' signal is caught.
 *
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
		const OptionEntry[] entries = {
			// general options
			{"forks",           0,   0, OptionArg.INT,            null, "Number of forks to create",            "0"},
			// address
			{"address",         'a', 0, OptionArg.STRING_ARRAY,   null, "Listen on each addresses",             "[]"},
			// port
			{"port",            'p', 0, OptionArg.STRING_ARRAY,   null, "Listen on each ports, '0' for random", "[]"},
			{"any",             'A', 0, OptionArg.NONE,           null, "Listen on any address instead of only from the loopback interface"},
			{"ipv4-only",       '4', 0, OptionArg.NONE,           null, "Listen only to IPv4 interfaces"},
			{"ipv6-only",       '6', 0, OptionArg.NONE,           null, "Listen only to IPv6 interfaces"},
			// socket
			{"socket",          's', 0, OptionArg.FILENAME_ARRAY, null, "Listen on each UNIX socket paths",     "[]"},
			// file descriptor
			{"file-descriptor", 'f', 0, OptionArg.STRING_ARRAY,   null, "Listen on each file descriptors",      "[]"},
			{null}
		};
		add_main_option_entries (entries);
	}

	public override int command_line (ApplicationCommandLine command_line) {
		var options = command_line.get_options_dict ().end ();

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
				               LogLevelFlags.LEVEL_INFO     in level ? "\x1b[34m" :
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
			var addresses = options.lookup_value ("address",         VariantType.STRING_ARRAY);
			var ports     = options.lookup_value ("port",            VariantType.STRING_ARRAY);
			var any       = options.lookup_value ("any",             VariantType.BOOLEAN);
			var ipv4_only = options.lookup_value ("ipv4-only",       VariantType.BOOLEAN);
			var ipv6_only = options.lookup_value ("ipv6-only",       VariantType.BOOLEAN);
			var sockets   = options.lookup_value ("socket",          VariantType.BYTESTRING_ARRAY);
			var fds       = options.lookup_value ("file-descriptor", VariantType.STRING_ARRAY);

			if (addresses != null) {
				foreach (var address in addresses.get_strv ()) {
					var net_address = NetworkAddress.parse (address, 0);
					var socket_address_iterator = net_address.enumerate ();
					SocketAddress socket_address;
					while ((socket_address = socket_address_iterator.next ()) != null) {
						server.listen (socket_address);
					}
				}
			}

			if (ports != null) {
				foreach (var _port in ports) {
					uint64 port;
					if (!uint64.try_parse (_port.get_string (), out port)) {
						critical ("Malformed port number '%s'.", _port.get_string ());
						return 1;
					}
					InetAddress address;
					InetAddress? extra_address = null;
					if (any != null) {
						if (ipv4_only != null) {
							address = new InetAddress.any (SocketFamily.IPV4);
						} else if (ipv6_only != null) {
							address = new InetAddress.any (SocketFamily.IPV6);
						} else {
							address       = new InetAddress.any (SocketFamily.IPV4);
							extra_address = new InetAddress.any (SocketFamily.IPV6);
						}
					} else {
						if (ipv4_only != null) {
							address = new InetAddress.loopback (SocketFamily.IPV4);
						} else if (ipv6_only != null) {
							address = new InetAddress.loopback (SocketFamily.IPV6);
						} else {
							address       = new InetAddress.loopback (SocketFamily.IPV4);
							extra_address = new InetAddress.loopback (SocketFamily.IPV6);
						}
					}
					server.listen (new InetSocketAddress (address, (uint16) port));
					if (extra_address != null) {
						try {
							server.listen (new InetSocketAddress (extra_address, (uint16) port));
						} catch (IOError.NOT_SUPPORTED err) {
							// ignore extra address if not supported
						}
					}
				}
			}

			// socket path
			if (sockets != null) {
				foreach (var socket in sockets.get_bytestring_array ()) {
					server.listen (new UnixSocketAddress (socket));
				}
			}

			// file descriptor
			if (fds != null) {
				foreach (var _fd in fds) {
					int64 fd;
					if (!int64.try_parse (_fd.get_string (), out fd)) {
						critical ("Malformed file descriptor '%s'.", _fd.get_string ());
						return 1;
					}
					server.listen_socket (new Socket.from_fd ((int) fd));
				}
			}

			// default listening interface
			if (addresses == null && ports == null && sockets == null && fds == null) {
				server.listen ();
			}

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
							warning ("Worker %d exited with status '%d'.", pid, status);
						});
					}
				}
			} catch (Error err) {
				critical ("%s (%s, %d)", err.message, err.domain.to_string (), err.code);
				return 1;
			}
		}

		foreach (var uri in server.uris) {
			message ("Listening on '%s'.", uri.to_string (false)[0:-uri.path.length]);
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
