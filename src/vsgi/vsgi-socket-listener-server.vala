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
 * Base for implementing a server upon {@link GLib.SocketService}.
 *
 * @since 0.3
 */
public abstract class VSGI.SocketListenerServer : Server {

	/**
	 * @since 0.3
	 */
	public SocketService socket_service { construct; get; }

	/**
	 * Identifier used to represent the protocol in URL scheme.
	 *
	 * @since 0.3
	 */
	protected abstract string protocol { get; }

	private SList<Soup.URI> _uris = new SList<Soup.URI> ();

	public override SList<Soup.URI> uris {
		get { return _uris; }
	}

	construct {
#if GIO_2_40
		const OptionEntry[] options = {
			{"any",             'a', 0, OptionArg.NONE,     null, "Listen on any open TCP port"},
			{"port",            'p', 0, OptionArg.INT,      null, "Listen to the provided TCP port"},
			{"file-descriptor", 'f', 0, OptionArg.INT,      null, "Listen to the provided file descriptor",       "0"},
			{"backlog",         'b', 0, OptionArg.INT,      null, "Listen queue depth used in the listen() call", "10"},
			{null}
		};

		this.add_main_option_entries (options);
#endif

		socket_service = new SocketService ();

		socket_service.incoming.connect (handle_incoming_socket_connection);

		socket_service.start ();

		// gracefully stop accepting new connections
		shutdown.connect (socket_service.stop);
	}

	public override void listen (Variant options) throws Error {
		if (options.lookup_value ("any", VariantType.BOOLEAN) != null) {
			var port = socket_service.add_any_inet_port (null);
			_uris.append (new Soup.URI ("%s://0.0.0.0:%u/".printf (protocol, port)));
			_uris.append (new Soup.URI ("%s://[::]:%u/".printf (protocol, port)));
		} else if (options.lookup_value ("port", VariantType.INT32) != null) {
			var port = (uint16) options.lookup_value ("port", VariantType.INT32).get_int32 ();
			socket_service.add_inet_port (port, null);
			_uris.append (new Soup.URI ("%s://0.0.0.0:%u/".printf (protocol, port)));
			_uris.append (new Soup.URI ("%s://[::]:%u/".printf (protocol, port)));
		} else if (options.lookup_value ("file-descriptor", VariantType.INT32) != null) {
			var file_descriptor = options.lookup_value ("file-descriptor", VariantType.INT32).get_int32 ();
			socket_service.add_socket (new Socket.from_fd (file_descriptor), null);
			_uris.append (new Soup.URI ("%s+fd://%u/".printf (protocol, file_descriptor)));
		} else {
			socket_service.add_socket (new Socket.from_fd (0), null);
			_uris.append (new Soup.URI ("%s+fd://0/".printf (protocol)));
		}

		if (options.lookup_value ("backlog", VariantType.INT32) != null) {
			socket_service.set_backlog (options.lookup_value ("backlog", VariantType.INT32).get_int32 ());
		}
	}

	/**
	 * Dispatch an incoming socket connection.
	 *
	 * @since 0.3
	 */
	public abstract bool handle_incoming_socket_connection (SocketConnection connection, Object? obj);
}
