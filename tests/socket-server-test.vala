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
using VSGI;

private class MockedSocketServer : SocketServer {

	protected override string scheme { get { return "mock"; } }

	protected override bool incoming (SocketConnection connection) {
		return true;
	}
}

public int main (string[] args) {
	Test.init (ref args);

	Test.add_func ("/socket_server/listen/any", () => {
		var server = new MockedSocketServer ();

		try {
			server.listen (new InetSocketAddress (new InetAddress.any (SocketFamily.IPV4), 0));
			server.listen (new InetSocketAddress (new InetAddress.any (SocketFamily.IPV6), 0));
		} catch (Error err) {
			assert_not_reached ();
		}

		assert (server.uris.data.to_string (false).has_prefix ("mock://0.0.0.0:"));
		assert (server.uris.next.data.to_string (false).has_prefix ("mock://[::]:"));
	});

	Test.add_func ("/socket_server/listen/default", () => {
		var server = new MockedSocketServer ();

		try {
			server.listen ();
		} catch (IOError.NOT_SUPPORTED err) {

		} catch (Error err) {
			assert_not_reached ();
		}

		assert (0 == server.uris.length ());
	});

	Test.add_func ("/socket_server/listen/unix_socket", () => {
#if GIO_UNIX
		var server = new MockedSocketServer ();

		try {
			server.listen (new UnixSocketAddress ("some-socket.sock"));
		} catch (Error err) {
			assert_not_reached ();
		} finally {
			FileUtils.unlink ("some-socket.sock");
		}

		assert ("mock+unix://some-socket.sock/" == server.uris.data.to_string (false));
#else
		Test.skip ("This test require 'gio-unix-2.0' installed.");
#endif
	});

	Test.add_func ("/socket_server/listen_socket", () => {
#if GIO_UNIX
		var server = new MockedSocketServer ();

		try {
			var socket = new Socket (SocketFamily.UNIX, SocketType.STREAM, SocketProtocol.DEFAULT);
			server.listen_socket (socket);
			assert ("mock+fd://%d/".printf (socket.fd) == server.uris.data.to_string (false));
		} catch (Error err) {
			assert_not_reached ();
		} finally {
			FileUtils.unlink ("some-socket.sock");
		}
#else
		Test.skip ("This test require 'gio-unix-2.0' installed.");
#endif
	});

	return Test.run ();
}
