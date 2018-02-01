using VSGI;
using Valum;

public int main (string[] args) {
	Test.init (ref args);

	Test.add_func ("/websocket", () => {
		// client
		var session = new Soup.Session ();
		var msg = new Soup.Message ("GET", "ws://localhost:3003/websocket");
		var loop = new MainLoop ();

		session.websocket_connect_async.begin (msg, null, {}, null, (obj, res) => {
			Soup.WebsocketConnection? connection;
			try {
				connection = session.websocket_connect_async.end (res);
			} catch (Error err) {
				assert_not_reached ();
			}

			assert (connection != null);

			connection.message.connect ((type, message) => {
				assert ("Hello world!" == (string) message.get_data ());
			});

			var has_sent_closing = false;
			connection.closing.connect (() => {
				has_sent_closing = true;
			});

			connection.closed.connect (() => {
				assert (has_sent_closing);
				assert (Soup.WebsocketCloseCode.NORMAL == connection.get_close_code ());
				assert ("Goodbye world!" == connection.get_close_data ());
				loop.quit ();
			});

			connection.send_text ("foo");
		});

		loop.run ();
	});

	return Test.run ();
}
