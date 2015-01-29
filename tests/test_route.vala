using Valum;

/**
 * TODO: test captures extraction
 *
 * @since 0.1
 */
public void test_route_new () {}

/**
 * @since 0.1
 */
public void test_route_from_rule () {
	var route  = new Route.from_rule (new Router (), "/<int:id>", (req, res) => {});

	/*
	var route = new Route.from_rule (router, "<int:id>", (req, res) => {});
	assert ("^(?<id>\\d+)$" == route.regex.get_pattern ());

	route = new Route.from_rule (router, "<id>", (req, res) => {});
	assert ("^(?<id>\\w+)$" == route.regex.get_pattern ());

	route = new Route.from_rule (router, "<any:id>", (req, res) => {});
	assert ("^(?<id>.+)$" == route.regex.get_pattern ());
	*/
}

/**
 * @since 0.1
 */
public void test_route_from_rule_without_captures () {
	var route  = new Route.from_rule (new Router (), "/", (req, res) => {});
	var req    = new TestRequest.with_uri (new Soup.URI ("http://localhost/"));

	assert (req.params == null);

	var matches = route.match (req);

	// ensure params are still null if there is no captures
	assert (matches);
	assert (req.params == null);
}

/**
 * @since 0.1
 */
public void test_route_from_regex () {
	var route  = new Route.from_regex (new Router (), /^\/(?<id>\d+)$/, (req, res) => {});
	var req    = new TestRequest.with_uri (new Soup.URI ("http://localhost/5"));

	assert (route.match (req));
}

/**
 * @since 0.1
 */
public void test_route_from_regex_without_captures () {
	var route  = new Route.from_regex (new Router (), /\//, (req, res) => {});
	var req    = new TestRequest.with_uri (new Soup.URI ("http://localhost/"));

	assert (req.params == null);

	var matches = route.match (req);

	// ensure params are still null if there is no captures
	assert (matches);
	assert (req.params == null);
}

/**
 * @since 0.1
 */
public void test_route_from_matcher () {
	var route  = new Route.from_matcher (new Router (), (req) => { return true; }, (req, res) => {});
	var req    = new TestRequest.with_uri (new Soup.URI ("http://localhost/5"));

	assert (route.match (req));

}

/**
 * @since 0.1
 */
public void test_route_match () {
	var route  = new Route.from_rule (new Router (), "/<int:id>", (req, res) => {});
	var req    = new TestRequest.with_uri (new Soup.URI ("http://localhost/5"));

	assert (req.params == null);

	var matches = route.match (req);

	assert (matches);
	assert_nonnull (req.params);
	assert (req.params.contains ("id"));
}

/**
 * @since 0.1
 */
public void test_route_match_not_matching () {
	var route  = new Route.from_rule (new Router (), "/<int:id>", (req, res) => {});
	var req    = new TestRequest.with_uri (new Soup.URI ("http://localhost/home"));

	// no match and params remains null
	assert (route.match (req) == false);
	assert (req.params == null);
}

/**
 * @since 0.1
 */
public void test_route_fire () {
	var setted = false;
	var route = new Route.from_rule (new Router (), "/<int:id>", (req, res) => {
		setted = true;
	});
	var req   = new TestRequest.with_uri (new Soup.URI ("http://localhost/home"));
	var res   = new TestResponse (req, 200);

	assert_false (setted);

	route.fire (req, res);

	assert (setted);
}
