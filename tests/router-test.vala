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

using Valum;
using VSGI.Test;

/**
 * @since 0.1
 */
public static void test_router () {
	var router = new Router ();

	assert (router.types != null);
	assert (router.types.contains ("int"));
	assert (router.types.contains ("string"));
	assert (router.types.contains ("path"));
	assert (router.types.contains ("any"));
}

/**
 * @since 0.2
 */
public static void test_router_handle () {
	var router = new Router ();

	router.get ("", (req, res) => {
		res.status = 418;
	});

	var request  = new Request.with_uri (new Soup.URI ("http://localhost/"));
	var response = new Response (request);

	router.handle (request, response);

	HashTable<string, string>? @params;
	assert (418 == response.status);
	assert ("text/html" == response.headers.get_content_type (out @params));
	assert (null != @params);
	assert ("charset" in @params);
	assert ("utf-8" == @params["charset"]);
}

/**
 * @since 0.1
 */
public static void test_router_get () {
	var router = new Router ();

	router.get ("", (req, res) => {
		res.status = 418;
	});

	var request  = new Request.with_uri (new Soup.URI ("http://localhost/"));
	var response = new Response (request);

	router.handle (request, response);

	assert (418 == response.status);
}

/**
 * @since 0.1
 */
public static void test_router_post () {
	var router = new Router ();

	router.post ("", (req, res) => {
		res.status = 418;
	});

	var request  = new Request.with_method (VSGI.Request.POST, new Soup.URI ("http://localhost/"));
	var response = new Response (request);

	router.handle (request, response);

	assert (418 == response.status);
}

/**
 * @since 0.1
 */
public static void test_router_put () {
	var router = new Router ();

	router.put ("", (req, res) => {
		res.status = 418;
	});

	var request  = new Request.with_method (VSGI.Request.PUT, new Soup.URI ("http://localhost/"));
	var response = new Response (request);

	router.handle (request, response);

	assert (418 == response.status);
}

/**
 * @since 0.1
 */
public static void test_router_delete () {
	var router = new Router ();

	router.delete ("", (req, res) => {
		res.status = 418;
	});

	var request  = new Request.with_method (VSGI.Request.DELETE, new Soup.URI ("http://localhost/"));
	var response = new Response (request);

	router.handle (request, response);

	assert (418 == response.status);
}

/**
 * @since 0.1
 */
public static void test_router_head () {
	var router = new Router ();

	router.head ("", (req, res) => {
		res.status = 418;
	});

	var request  = new Request.with_method (VSGI.Request.HEAD, new Soup.URI ("http://localhost/"));
	var response = new Response (request);

	router.handle (request, response);

	assert (418 == response.status);
}

/**
 * @since 0.1
 */
public static void test_router_options () {
	var router = new Router ();

	router.options ("", (req, res) => {
		res.status = 418;
	});

	var request  = new Request.with_method (VSGI.Request.OPTIONS, new Soup.URI ("http://localhost/"));
	var response = new Response (request);

	router.handle (request, response);

	assert (418 == response.status);
}

/**
 * @since 0.1
 */
public static void test_router_trace () {
	var router = new Router ();

	router.trace ("", (req, res) => {
		res.status = 418;
	});

	var request  = new Request.with_method (VSGI.Request.TRACE, new Soup.URI ("http://localhost/"));
	var response = new Response (request);

	router.handle (request, response);

	assert (418 == response.status);
}

/**
 * @since 0.1
 */
public static void test_router_connect () {
	var router = new Router ();

	router.connect ("", (req, res) => {
		res.status = 418;
	});

	var request  = new Request.with_method (VSGI.Request.CONNECT, new Soup.URI ("http://localhost/"));
	var response = new Response (request);

	router.handle (request, response);

	assert (418 == response.status);
}
/**
 * @since 0.1
 */
public static void test_router_patch () {
	var router = new Router ();

	router.patch ("", (req, res) => {
		res.status = 418;
	});

	var request  = new Request.with_method (VSGI.Request.PATCH, new Soup.URI ("http://localhost/"));
	var response = new Response (request);

	router.handle (request, response);

	assert (418 == response.status);
}

/**
 * @since 0.1
 */
public static void test_router_methods () {
	var router       = new Router ();
	string[] methods = {VSGI.Request.GET, VSGI.Request.POST};

	var routes = router.methods (methods, "", (req, res) => {
		res.status = 418;
	});

	assert (2 == routes.length);
	assert (methods[0] == routes[0].method);
	assert (methods[1] == routes[1].method);

	foreach (var method in methods) {
		var request  = new Request.with_method (method, new Soup.URI ("http://localhost/"));
		var response = new Response (request);

		router.handle (request, response);

		assert (418 == response.status);
	}
}

/**
 * @since 0.1
 */
public static void test_router_all () {
	var router = new Router ();

	var routes = router.all ("", (req, res) => {
		res.status = 418;
	});

	assert (VSGI.Request.METHODS.length == routes.length);

	for (int i = 0; i < routes.length; i++)
		assert (VSGI.Request.METHODS[i] == routes[i].method);

	foreach (var method in VSGI.Request.METHODS) {
		var request  = new Request.with_method (method, new Soup.URI ("http://localhost/"));
		var response = new Response (request);

		router.handle (request, response);

		assert (418 == response.status);
	}
}

/**
 * @since 0.1
 */
public static void test_router_regex () {
	var router = new Router ();

	router.regex (VSGI.Request.GET, /home/, (req, res) => {
		res.status = 418;
	});

	var request  = new Request.with_uri (new Soup.URI ("http://localhost/home"));
	var response = new Response (request);

	router.handle (request, response);

	assert (418 == response.status);
}

/**
 * @since 0.1
 */
public static void test_router_matcher () {
	var router = new Router ();

	router.matcher (VSGI.Request.GET, (req) => { return req.uri.get_path () == "/"; }, (req, res) => {
		res.status = 418;
	});

	var request  = new Request.with_uri (new Soup.URI ("http://localhost/"));
	var response = new Response (request);

	router.handle (request, response);

	assert (418 == response.status);
}

/**
 * @since 0.1
 */
public static void test_router_scope () {
	var router = new Router ();

	router.scope ("test", (inner) => {
		inner.get ("test", (req, res) => {
			res.status = 418; // I'm a teapot
		});
	});

	var request = new Request.with_uri (new Soup.URI ("http://localhost/test/test"));
	var response = new Response (request);

	router.handle (request, response);

	assert (response.status == 418);
}

/**
 * @since 0.1
 */
public static void test_router_informational_switching_protocols () {
	var router = new Router ();

	router.all ("", (req, res) => {
		throw new Informational.SWITCHING_PROTOCOLS ("HTTP/1.1");
	});

	var request  = new Request.with_uri (new Soup.URI ("http://localhost/"));
	var response = new Response (request);

	router.handle (request, response);

	assert (response.status == Soup.Status.SWITCHING_PROTOCOLS);
	assert ("HTTP/1.1" == response.headers.get_one ("Upgrade"));
}

/**
 * @since 0.1
 */
public static void test_router_success_created () {
	var router = new Router ();

	router.put ("document", (req, res) => {
		throw new Success.CREATED ("/document/5");
	});

	var request  = new Request.with_method (VSGI.Request.PUT, new Soup.URI ("http://localhost/document"));
	var response = new Response (request);

	router.handle (request, response);

	assert (Soup.Status.CREATED == response.status);
	assert ("/document/5" == response.headers.get_one ("Location"));
	assert (response.head_written);
}

/**
 * @since 0.1
 */
public static void test_router_success_partial_content () {
	var router = new Router ();

	router.put ("document", (req, res) => {
		throw new Success.PARTIAL_CONTENT ("bytes 21010-47021/47022");
	});

	var request  = new Request.with_method (VSGI.Request.PUT, new Soup.URI ("http://localhost/document"));
	var response = new Response (request);

	router.handle (request, response);

	assert (Soup.Status.PARTIAL_CONTENT == response.status);
	assert ("bytes 21010-47021/47022" == response.headers.get_one ("Range"));
}

/**
 * @since 0.1
 */
public static void test_router_redirection () {
	var router = new Router ();

	router.get ("", (req, res) => {
		throw new Redirection.MOVED_TEMPORARILY ("http://example.com");
	});

	var request = new Request.with_uri (new Soup.URI ("http://localhost/"));
	var response = new Response (request);

	router.handle (request, response);

	assert (response.status == Soup.Status.MOVED_TEMPORARILY);
	assert ("http://example.com" == response.headers.get_one ("Location"));
	assert (response.head_written);
}

/**
 * @since 0.1
 */
public static void test_router_client_error_method_not_allowed () {
	var router = new Router ();

	router.post ("", (req, res) => {

	});

	router.all ("", (req, res) => {
		throw new ClientError.METHOD_NOT_ALLOWED ("POST");
	});

	var request  = new Request.with_uri (new Soup.URI ("http://localhost/"));
	var response = new Response (request);

	router.handle (request, response);

	assert (Soup.Status.METHOD_NOT_ALLOWED == response.status);
	assert ("POST" == response.headers.get_one ("Allow"));
	assert (response.head_written);
}

/**
 * @since 0.1
 */
public static void test_router_client_error_upgrade_required () {
	var router = new Router ();

	router.all ("", (req, res) => {
		throw new ClientError.UPGRADE_REQUIRED ("HTTP/1.1");
	});

	var request  = new Request.with_uri (new Soup.URI ("http://localhost/"));
	var response = new Response (request);

	router.handle (request, response);

	assert (426 == response.status);
	assert ("HTTP/1.1" == response.headers.get_one ("Upgrade"));
	assert (response.head_written);
}

/**
 * @since 0.1
 */
public static void test_router_server_error () {
	var router = new Router ();

	router.get ("", (req, res) => {
		throw new ServerError.INTERNAL_SERVER_ERROR ("Teapot's burning!");
	});

	var request  = new Request.with_uri (new Soup.URI ("http://localhost/"));
	var response = new Response (request);

	router.handle (request, response);

	var body = (MemoryOutputStream) request.connection.output_stream;
	HashTable<string, string> @params;

	assert (response.status == Soup.Status.INTERNAL_SERVER_ERROR);
	assert (response.head_written);
	assert ("text/plain" == response.headers.get_content_type (out @params));
	assert ("charset" in @params);
	assert ("utf-8" == @params["charset"]);
	assert (17 == response.headers.get_content_length ());
	assert ("Teapot's burning!" in (string) body.get_data ());
}

/**
 * @since 0.1
 */
public static void test_router_custom_method () {
	var router = new Router ();

	router.method ("TEST", "", (req, res) => {
		res.status = 418;
	});

	var request = new Request.with_method ("TEST", new Soup.URI ("http://localhost/"));
	var response = new Response (request);

	router.handle (request, response);

	assert (response.status == 418);
}

/**
 * @since 0.1
 */
public static void test_router_method_not_allowed () {
	var router = new Router ();

	router.get ("", (req, res) => {

	});

	router.put ("", (req, res) => {

	});

	var request = new Request.with_method ("POST", new Soup.URI ("http://localhost/"));
	var response = new Response.with_status (request, Soup.Status.METHOD_NOT_ALLOWED);

	router.handle (request, response);

	assert (response.status == 405);
	assert ("GET, PUT" == response.headers.get_one ("Allow"));
	assert (response.head_written);
}

/**
 * @since 0.1
 */
public static void test_router_method_not_allowed_excludes_request_method () {
	var router = new Router ();

	var get_matched  = 0;
	var post_matched = 0;

	// matching, but not the same HTTP method
	router.matcher (VSGI.Request.GET, () => { get_matched++; return true; }, (req, res) => {

	});

	// not matching, but same HTTP method
	router.matcher (VSGI.Request.POST, () => { post_matched++; return false; }, (req, res) => {

	});

	var request = new Request.with_method ("POST", new Soup.URI ("http://localhost/"));
	var response = new Response.with_status (request, Soup.Status.METHOD_NOT_ALLOWED);

	router.handle (request, response);

	assert (post_matched == 1); // matched only once during initial lookup
	assert (get_matched == 1);

	assert (response.status == 405);
	assert ("GET" == response.headers.get_one ("Allow"));
	assert (response.head_written);
}

/**
 * @since 0.1
 */
public static void test_router_not_found () {
	var router = new Router ();

	var request = new Request.with_uri (new Soup.URI ("http://localhost/"));
	var response = new Response (request);

	router.handle (request, response);

	assert (Soup.Status.NOT_FOUND == response.status);
	assert (response.head_written);
}


/**
 * @since 0.1
 */
public static void test_router_subrouting () {
	var router    = new Router ();
	var subrouter = new Router ();

	subrouter.get ("", (req, res) => {
		res.status = 418;
	});

	router.get ("", subrouter.handle);

	var request = new Request.with_uri (new Soup.URI ("http://localhost/"));
	var response = new Response.with_status (request, Soup.Status.NOT_FOUND);

	router.handle (request, response);

	assert (418 == response.status);
}

/**
 * @since 0.1
 */
public static void test_router_next () {
	var router = new Router ();

	router.get ("", (req, res, next) => {
		next (req, res);
	});

	// should recurse a bit in process_routing
	router.get ("", (req, res, next) => {
		next (req, res);
	});

	router.get ("", (req, res, next) => {
		res.status = 418;
	});

	var request = new Request.with_uri (new Soup.URI ("http://localhost/"));
	var response = new Response.with_status (request, Soup.Status.NOT_FOUND);

	router.handle (request, response);

	assert (418 == response.status);
}

public static void test_router_next_not_found () {
	var router = new Router ();

	router.get ("", (req, res, next) => {
		next (req, res);
	});

	// should recurse a bit in process_routing
	router.get ("", (req, res, next) => {
		next (req, res);
	});

	// no more route matching

	var request = new Request.with_uri (new Soup.URI ("http://localhost/"));
	var response = new Response (request);

	router.handle (request, response);

	assert (404 == response.status);
}

/**
 * @since 0.1
 */
public static void test_router_next_propagate_error () {
	var router = new Router ();

	router.get ("", (req, res, next) => {
		next (req, res);
	});

	router.get ("", (req, res, next) => {
		next (req, res);
	});

	router.get ("", (req, res, next) => {
		throw new ClientError.UNAUTHORIZED ("");
	});

	var request = new Request.with_uri (new Soup.URI ("http://localhost/"));
	var response = new Response (request);

	router.handle (request, response);

	assert (401 == response.status);
}

/**
 * @since 0.1
 */
public static void test_router_next_propagate_state () {
	var router = new Router ();
	var state  = new Object ();

	router.get ("", (req, res, next, stack) => {
		stack.push_tail (state);
		next (req, res);
	});

	router.get ("", (req, res, next) => {
		next (req, res);
	});

	router.get ("", (req, res, next, st) => {
		res.status = 413;
		assert (st.pop_tail () == state);
	});

	var request = new Request.with_uri (new Soup.URI ("http://localhost/"));
	var response = new Response (request);

	router.handle (request, response);

	assert (413 == response.status);
}

/**
 * @since 0.1
 */
public static void test_router_next_replace_propagated_state () {
	var router = new Router ();
	var state  = new Object ();

	router.get ("", (req, res, next, stack) => {
		stack.push_tail (state);
		next (req, res);
	});

	router.get ("", (req, res, next, stack) => {
		assert (state == stack.pop_tail ());
		next (req, res);
	});

	router.get ("", (req, res, next, stack) => {
		res.status = 413;
		assert (stack.is_empty ());
	});

	var request = new Request.with_uri (new Soup.URI ("http://localhost/"));
	var response = new Response (request);

	router.handle (request, response);

	assert (413 == response.status);
}

public static void test_router_status_propagates_error_message () {
	var router = new Router ();

	router.status (404, (req, res, next, stack) => {
		var message = stack.pop_tail ();
		res.status = 418;
		assert ("The request URI http://localhost/ was not found." == message.get_string ());
	});

	var request = new Request.with_uri (new Soup.URI ("http://localhost/"));
	var response = new Response (request);

	router.handle (request, response);

	assert (418 == response.status);
}

/**
 * @since 0.2.2
 */
public void test_router_status_handle_error () {
	var router = new Router ();

	router.get ("", (req, res) => {
		throw new IOError.FAILED ("Just failed!");
	});

	router.status (500, (req, res) => {
		res.status = 418;
	});

	var req = new Request.with_uri (new Soup.URI ("http://localhost/"));
	var res = new Response (req);

	router.handle (req, res);

	assert (418 == res.status);
}

/**
 * @since 0.2
 */
public static void test_router_invoke () {
	var router = new Router ();

	router.get ("", (req, res, next) => {
		router.invoke (req, res, next);
	});

	router.get ("", (req, res) => {
		throw new ClientError.IM_A_TEAPOT ("this is insane!");
	});

	var request  = new Request.with_uri (new Soup.URI ("http://localhost/"));
	var response = new Response (request);

	router.handle (request, response);

	assert (418 == response.status);
}

/**
 * @since 0.2
 */
public static void test_router_invoke_propagate_state () {
	var router  = new Router ();
	var message = "test";

	router.get ("", (req, res, next, stack) => {
		stack.push_tail (message);
		router.invoke (req, res, next);
	});

	router.get ("", (req, res, next, stack) => {
		assert (message == stack.pop_tail ().get_string ());
		throw new ClientError.IM_A_TEAPOT ("this is insane!");
	});

	var request  = new Request.with_uri (new Soup.URI ("http://localhost/"));
	var response = new Response (request);

	router.handle (request, response);

	assert (418 == response.status);
}

/**
 * @since 0.2
 */
public void test_router_then () {
	var router = new Router ();

	var setted      = false;
	var then_setted = false;

	router.get ("<int:id>", (req, res, next) => {
		setted = true;
		next (req, res);
	}).then ((req, res) => {
		assert (setted);
		then_setted = true;
	});

	var req = new Request.with_uri (new Soup.URI ("http://localhost/5"));
	var res = new Response (req);

	router.handle (req, res);

	assert (setted);
	assert (then_setted);
}

/**
  * @since 0.2.2
  */
public void test_router_then_preserve_matching_stack () {
	var router = new Router ();

	var reached = false;

	router.get ("<int:id>", (req, res, next, stack) => {
		stack.push_tail ("test");
		next (req, res);
	}).then ((req, res, next, stack) => {
		reached = true;
		assert ("test" == stack.pop_tail ().get_string ());
		assert ("5" == stack.pop_tail ().get_string ());
	});

	var req = new Request.with_uri (new Soup.URI ("http://localhost/5"));
	var res = new Response (req);

	router.handle (req, res);

	assert (reached);
}

/**
 * @since 0.2.1
 */
public void test_router_error () {
	var router = new Router ();

	router.get ("", (req, res) => {
		throw new IOError.FAILED ("Just failed!");
	});

	var req = new Request.with_uri (new Soup.URI ("http://localhost/"));
	var res = new Response (req);

	router.handle (req, res);

	assert (500 == res.status);
}

