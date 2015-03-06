using Valum;

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
public static void test_router_scope () {
	var router = new Router ();

	router.scope ("test", (inner) => {
		inner.get ("test", (req, res) => {
			res.status = 418; // I'm a teapot
		});
	});

	var request = new TestRequest.with_uri (new Soup.URI ("http://localhost/test/test"));
	var response = new TestResponse (request, Soup.Status.OK);

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

	var request = new TestRequest.with_uri (new Soup.URI ("http://localhost/"));
	var response = new TestResponse (request, Soup.Status.OK);

	router.handle (request, response);

	assert (response.status == Soup.Status.MOVED_TEMPORARILY);
	assert ("http://example.com" == response.headers.get_one ("Location"));
}

/**
 * @since 0.1
 */
public static void test_router_custom_method () {
	var router = new Router ();

	router.method ("TEST", "", (req, res) => {
		res.status = 418;
	});

	var request = new TestRequest ("TEST", new Soup.URI ("http://localhost/"));
	var response = new TestResponse (request, Soup.Status.OK);

	router.handle (request, response);

	assert (response.status == 418);
}
