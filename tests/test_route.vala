using Valum;
using VSGI.Test;

/**
 * @since 0.1
 */
public void test_route () {
	var route  = new Route (new Router (), (req) => { return true; }, (req, res) => {});
	var req    = new Request.with_uri (new Soup.URI ("http://localhost/5"));

	assert (route.match (req));

}

/**
 * @since 0.1
 */
public void test_route_from_rule () {
	var route  = new Route.from_rule (new Router (), "<int:id>", (req, res) => {});
	var request = new Request.with_uri (new Soup.URI ("http://localhost/5"));

	assert (route.match (request));
	assert (request.params != null);
	assert (request.params["id"] == "5");
}

/**
 * @since 0.1
 */
public void test_route_from_rule_any () {
	var route  = new Route.from_rule (new Router (), "<any:id>", (req, res) => {});
	var request = new Request.with_uri (new Soup.URI ("http://localhost/5"));

	assert (route.match (request));
	assert (request.params != null);
	assert (request.params["id"] == "5");
}

/**
 * @since 0.1
 */
public void test_route_from_rule_without_captures () {
	var route  = new Route.from_rule (new Router (), "", (req, res) => {});
	var req    = new Request.with_uri (new Soup.URI ("http://localhost/"));

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
	var route  = new Route.from_regex (new Router (), /(?<id>\d+)/, (req, res) => {});
	var req    = new Request.with_uri (new Soup.URI ("http://localhost/5"));

	assert (req.params == null);

	var matches = route.match (req);

	assert (matches);
	assert (req.params != null);
	assert (req.params["id"] == "5");
}

/**
 * @since 0.1
 */
public void test_route_from_regex_scoped () {
	var router = new Router ();

	router.scopes.push_tail ("test");

	var route  = new Route.from_regex (router, /(?<id>\d+)/, (req, res) => {});
	var req    = new Request.with_uri (new Soup.URI ("http://localhost/test/5"));

	assert (req.params == null);

	var matches = route.match (req);

	assert (matches);
	assert (req.params != null);
	assert (req.params["id"] == "5");
}

/**
 * @since 0.1
 */
public void test_route_from_regex_without_captures () {
	var route  = new Route.from_regex (new Router (), /.*/, (req, res) => {});
	var req    = new Request.with_uri (new Soup.URI ("http://localhost/"));

	var matches = route.match (req);

	// ensure params are still null if there is no captures
	assert (route.match (req));
	assert (req.params == null);
}

/**
 * @since 0.1
 */
public void test_route_match () {
	var route  = new Route.from_rule (new Router (), "<int:id>", (req, res) => {});
	var req    = new Request.with_uri (new Soup.URI ("http://localhost/5"));

	assert (req.params == null);

	var matches = route.match (req);

	assert (matches);
	assert (req.params != null);
	assert (req.params.contains ("id"));
}

/**
 * @since 0.1
 */
public void test_route_match_not_matching () {
	var route  = new Route.from_rule (new Router (), "<int:id>", (req, res) => {});
	var req    = new Request.with_uri (new Soup.URI ("http://localhost/home"));

	// no match and params remains null
	assert (route.match (req) == false);
	assert (req.params == null);
}

/**
 * @since 0.1
 */
public void test_route_fire () {
	var setted = false;
	var route = new Route.from_rule (new Router (), "<int:id>", (req, res) => {
		setted = true;
	});
	var req   = new Request.with_uri (new Soup.URI ("http://localhost/home"));
	var res   = new Response (req, 200);

	assert (setted == false);

	route.fire (req, res);

	assert (setted);
}
