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
using Valum;
using Valum.ServerSentEvents;
using VSGI;

/**
 * @since 0.3
 */
public void test_server_sent_events_send () {
	var router = new Router ();

	router.get ("/", stream_events ((req, send) => {
		send ("important", "some event", "1234", TimeSpan.MILLISECOND);
	}));

	var req_body = new MemoryInputStream ();
	var res_body = new MemoryOutputStream.resizable ();
	var req = new Request (null, "GET", new Soup.URI ("http://127.0.0.1:3003/"), null, req_body);
	var res = new Response (req, Soup.Status.OK, null, res_body);

	try {
		router.handle (req, res);
	} catch (Error err) {
		assert_not_reached ();
	}

	try {
		assert (res.body.close ());
	} catch (IOError err) {
		assert_not_reached ();
	}

	try {
		var expected_message = resources_lookup_data ("/data/server-sent-events/send-expected-message",
													  ResourceLookupFlags.NONE);

		var data = res_body.steal_data ();
		data.length = (int) res_body.get_data_size ();

		assert (expected_message.compare (new Bytes (data)) == 0);
	} catch (Error err) {
		assert_not_reached ();
	}
}

public void test_server_sent_events_send_multiline () {
	var router = new Router ();

	router.get ("/", stream_events ((req, send) => {
		send (null, "some event\nmore details");
	}));

	var req_body = new MemoryInputStream ();
	var res_body = new MemoryOutputStream.resizable ();
	var req = new Request (null, "GET", new Soup.URI ("http://127.0.0.1:3003/"), null, req_body);
	var res = new Response (req, Soup.Status.OK, null, res_body);

	try {
		router.handle (req, res);
	} catch (Error err) {
		assert_not_reached ();
	}

	try {
		assert (res.body.close ());
	} catch (IOError err) {
		assert_not_reached ();
	}

	try {
		var expected_message = resources_lookup_data ("/data/server-sent-events/send-multiline-expected-message",
													  ResourceLookupFlags.NONE);

		var data = res_body.steal_data ();
		data.length = (int) res_body.get_data_size ();

		assert (expected_message.compare (new Bytes (data)) == 0);
	} catch (Error err) {
		assert_not_reached ();
	}
}

public void test_server_sent_events_skip_on_head () {
	var router = new Router ();

	router.get ("/", stream_events ((req, send) => {
		assert_not_reached ();
	}));

	var req = new Request (null, "HEAD", new Soup.URI ("http://127.0.0.1:3003/"));
	var res = new Response (req);

	try {
		router.handle (req, res);
	} catch (Error err) {
		assert_not_reached ();
	}

	HashTable<string, string> @params;
	assert ("text/event-stream" == res.headers.get_content_type (out @params));
}
