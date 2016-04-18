using VSGI.FastCGI;

public int main (string[] args) {
	Test.init (ref args);

	Test.add_func ("/fastcgi/server/port", () => {
		var server = new Server ("org.vsgi.FastCGI", () => { return true; });

		var options = new VariantBuilder (new VariantType ("a{sv}"));

		options.add ("{sv}", "port", new Variant.@int32 (3003));

		try {
			server.listen (options.end ());
		} catch (Error err) {
			assert_not_reached ();
		}

		assert (1 == server.uris.length ());
		assert ("fcgi://0.0.0.0:3003/" == server.uris.data.to_string (false));
	});

	Test.add_func ("/fastcgi/server/socket", () => {
		var server = new Server ("org.vsgi.FastCGI", () => { return true; });

		var options = new VariantBuilder (new VariantType ("a{sv}"));

		options.add ("{sv}", "socket", new Variant.bytestring ("some-socket.sock"));

		try {
			server.listen (options.end ());
		} catch (Error err) {
			assert_not_reached ();
		} finally {
			FileUtils.unlink ("some-socket.sock");
		}

		assert (1 == server.uris.length ());
		assert ("fcgi+unix://some-socket.sock/" == server.uris.data.to_string (false));
	});

	return Test.run ();
}
