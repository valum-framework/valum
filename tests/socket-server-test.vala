
using GLib;
using VSGI;

private class MockedSocketServer : SocketServer {
	protected override string protocol {
		get {
			return "mock";
		}
	}

	protected override bool incoming (SocketConnection connection) {
		return true;
	}
}

public int main (string[] args) {
	Test.init (ref args);

	Test.add_func ("/socket_server/port", () => {
		var server = new MockedSocketServer ();
		var port   = Random.int_range (1024, 32768);
		server.set_application_callback (() => { return true; });

		var options = new VariantBuilder (new VariantType ("a{sv}"));

		options.add ("{sv}", "port", new Variant.@int32 (port));

		try {
			server.listen (options.end ());
		} catch (Error err) {
		message (err.message);
			assert_not_reached ();
		}

		assert ("mock://0.0.0.0:%d/".printf (port) == server.uris.data.to_string (false));
		assert ("mock://[::]:%d/".printf (port) == server.uris.next.data.to_string (false));
	});

	Test.add_func ("/socket_server/any_port", () => {
		var server = new MockedSocketServer ();
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

	Test.add_func ("/socket_server/file_descriptor", () => {
		var server = new MockedSocketServer ();
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
