
using GLib;
using VSGI;

private class MockedSocketListenerServer : SocketListenerServer {
	protected override string protocol {
		get {
			return "mock";
		}
	}

	protected override bool handle_incoming_socket_connection (SocketConnection connection, Object? obj) {
		return true;
	}
}

public int main (string[] args) {
	Test.init (ref args);

	Test.add_func ("/socket_listener_server/port", () => {
		var server = new MockedSocketListenerServer ();
		server.set_application_callback (() => { return true; });

		var options = new VariantBuilder (new VariantType ("a{sv}"));

		options.add ("{sv}", "port", new Variant.@int32 (3003));

		try {
			server.listen (options.end ());
		} catch (Error err) {
		message (err.message);
			assert_not_reached ();
		}

		assert ("mock://0.0.0.0:3003/" == server.uris.data.to_string (false));
		assert ("mock://[::]:3003/" == server.uris.next.data.to_string (false));
	});

	Test.add_func ("/socket_listener_server/any_port", () => {
		var server = new MockedSocketListenerServer ();
		server.set_application_callback (() => { return true; });

		var options = new VariantBuilder (new VariantType ("a{sv}"));

		options.add ("{sv}", "any", new Variant.boolean (true));

		try {
			server.listen (options.end ());
		} catch (Error err) {
		message (err.message);
			assert_not_reached ();
		}

		assert (server.uris.data.to_string (false).has_prefix ("mock://0.0.0.0:"));
		assert (server.uris.next.data.to_string (false).has_prefix ("mock://[::]:"));
	});

	Test.add_func ("/socket_listener_server/file_descriptor", () => {
		var server = new MockedSocketListenerServer ();
		server.set_application_callback (() => { return true; });

		try {
			var socket = new Socket (SocketFamily.UNIX, SocketType.STREAM, SocketProtocol.DEFAULT);
			socket.bind (new UnixSocketAddress ("some-socket.sock"), false);

			var options = new VariantBuilder (new VariantType ("a{sv}"));

			options.add ("{sv}", "file-descriptor", new Variant.@int32 (socket.get_fd ()));

			server.listen (options.end ());

			assert ("mock+fd://%d/".printf (socket.fd) == server.uris.data.to_string (false));
		} catch (Error err) {
			message (err.message);
			assert_not_reached ();
		} finally {
			FileUtils.unlink ("some-socket.sock");
		}
	});

	return Test.run ();
}
