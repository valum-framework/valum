using Valum;
using VSGI.Test;

/**
 * @since 0.3
 */
public void test_server_sent_events_send () {
	var router = new Router ();

	router.get ("", ServerSentEvents.context ((req, send) => {
		send (null, "some event");
	}));

	var connection = new Connection ();
	var req = new Request (connection, "GET", new Soup.URI ("http://127.0.0.1:3003/"));
	var res = new Response (req);

	router.handle (req, res);

	assert (res.body.close ());

	var expected_message = resources_lookup_data ("/data/server-sent-events/send-expected-message",
	                                              ResourceLookupFlags.NONE);

	assert (expected_message.compare (connection.memory_output_stream.steal_as_bytes ()) == 0);
}

public void test_server_sent_events_send_multiline () {
	var router = new Router ();

	router.get ("", ServerSentEvents.context ((req, send) => {
		send (null, "some event\nmore details");
	}));

	var connection = new Connection ();
	var req = new Request (connection, "GET", new Soup.URI ("http://127.0.0.1:3003/"));
	var res = new Response (req);

	router.handle (req, res);

	assert (res.body.close ());

	var expected_message = resources_lookup_data ("/data/server-sent-events/send-multiline-expected-message",
	                                              ResourceLookupFlags.NONE);

	assert (expected_message.compare (connection.memory_output_stream.steal_as_bytes ()) == 0);
}
