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
 * @since 0.1
 */
public static void test_router_get () {
	var router = new Router ();

	router.get ("", (req, res) => {
		res.status = 418;
	});

	var request  = new Request (VSGI.Request.GET, new Soup.URI ("http://localhost/"));
	var response = new Response (request, Soup.Status.OK);

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

	var request  = new Request (VSGI.Request.POST, new Soup.URI ("http://localhost/"));
	var response = new Response (request, Soup.Status.OK);

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

	var request  = new Request (VSGI.Request.PUT, new Soup.URI ("http://localhost/"));
	var response = new Response (request, Soup.Status.OK);

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

	var request  = new Request (VSGI.Request.DELETE, new Soup.URI ("http://localhost/"));
	var response = new Response (request, Soup.Status.OK);

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

	var request  = new Request (VSGI.Request.HEAD, new Soup.URI ("http://localhost/"));
	var response = new Response (request, Soup.Status.OK);

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

	var request  = new Request (VSGI.Request.OPTIONS, new Soup.URI ("http://localhost/"));
	var response = new Response (request, Soup.Status.OK);

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

	var request  = new Request (VSGI.Request.TRACE, new Soup.URI ("http://localhost/"));
	var response = new Response (request, Soup.Status.OK);

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

	var request  = new Request (VSGI.Request.CONNECT, new Soup.URI ("http://localhost/"));
	var response = new Response (request, Soup.Status.OK);

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

	var request  = new Request (VSGI.Request.PATCH, new Soup.URI ("http://localhost/"));
	var response = new Response (request, Soup.Status.OK);

	router.handle (request, response);

	assert (418 == response.status);
}

/**
 * @since 0.1
 */
public static void test_router_regex () {
	var router = new Router ();

	router.regex (VSGI.Request.GET, /home/, (req, res) => {
		res.status = 418;
	});

	var request  = new Request (VSGI.Request.GET, new Soup.URI ("http://localhost/home"));
	var response = new Response (request, Soup.Status.OK);

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

	var request  = new Request (VSGI.Request.GET, new Soup.URI ("http://localhost/"));
	var response = new Response (request, Soup.Status.OK);

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
	var response = new Response (request, Soup.Status.OK);

	router.handle (request, response);

	assert (response.status == 418);
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
	var response = new Response (request, Soup.Status.OK);

	router.handle (request, response);

	assert (response.status == Soup.Status.MOVED_TEMPORARILY);
	assert ("http://example.com" == response.headers.get_one ("Location"));
}

public static void test_router_server_error () {
	var router = new Router ();

	router.get ("", (req, res) => {
		throw new ServerError.INTERNAL_SERVER_ERROR ("Teapot's burning!");
	});

	var request = new Request.with_uri (new Soup.URI ("http://localhost/"));
	var response = new Response (request, Soup.Status.OK);

	router.handle (request, response);

	assert (response.status == Soup.Status.INTERNAL_SERVER_ERROR);
}

/**
 * @since 0.1
 */
public static void test_router_custom_method () {
	var router = new Router ();

	router.method ("TEST", "", (req, res) => {
		res.status = 418;
	});

	var request = new Request ("TEST", new Soup.URI ("http://localhost/"));
	var response = new Response (request, Soup.Status.OK);

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

	var request = new Request ("POST", new Soup.URI ("http://localhost/"));
	var response = new Response (request, Soup.Status.METHOD_NOT_ALLOWED);

	router.handle (request, response);

	assert (response.status == 405);
	assert ("PUT, GET" == response.headers.get_one ("Allow"));
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

	var request = new Request (VSGI.Request.GET, new Soup.URI ("http://localhost/"));
	var response = new Response (request, Soup.Status.NOT_FOUND);

	router.handle (request, response);

	assert (418 == response.status);
}

/**
 * @since 0.1
 */
public static void test_router_next () {
	var router = new Router ();

	router.get ("", (req, res, next) => {
		next ();
	});

	// should recurse a bit in process_routing
	router.get ("", (req, res, next) => {
		next ();
	});

	router.get ("", (req, res, next) => {
		res.status = 418;
	});

	var request = new Request (VSGI.Request.GET, new Soup.URI ("http://localhost/"));
	var response = new Response (request, Soup.Status.NOT_FOUND);

	router.handle (request, response);

	assert (418 == response.status);
}

public static void test_router_next_not_found () {
	var router = new Router ();

	router.get ("", (req, res, next) => {
		next ();
	});

	// should recurse a bit in process_routing
	router.get ("", (req, res, next) => {
		next ();
	});

	// no more route matching

	var request = new Request (VSGI.Request.GET, new Soup.URI ("http://localhost/"));
	var response = new Response (request, Soup.Status.OK);

	router.handle (request, response);

	assert (404 == response.status);
}
