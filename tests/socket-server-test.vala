
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

	Test.add_func ("/socket_server/listen/loopback", () => {
		var server = new MockedSocketServer ();

		try {
			server.listen (new InetSocketAddress (new InetAddress.loopback (SocketFamily.IPV4), 0));
			server.listen (new InetSocketAddress (new InetAddress.loopback (SocketFamily.IPV6), 0));
		} catch (Error err) {
			assert_not_reached ();
		}

		assert (server.uris.data.to_string (false).has_prefix ("mock://127.0.0.1:"));
		assert (server.uris.next.data.to_string (false).has_prefix ("mock://[::1]:"));
	});

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
		var server = new MockedSocketServer ();

		try {
			server.listen (new UnixSocketAddress ("some-socket.sock"));
		} catch (Error err) {
			assert_not_reached ();
		} finally {
			FileUtils.unlink ("some-socket.sock");
		}

		assert ("mock+unix://some-socket.sock/" == server.uris.data.to_string (false));
	});

	Test.add_func ("/socket_server/listen_socket", () => {
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
	});

	return Test.run ();
}
