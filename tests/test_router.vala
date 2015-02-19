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
