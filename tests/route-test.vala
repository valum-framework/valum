using Valum;
using VSGI.Test;

/**
 * @since 0.1
 */
public void test_route () {
	var router = new Router ();
	var route  = new Route (router, "GET", (req) => { return true; }, (req, res) => {});
	var req    = new Request.with_uri (new Soup.URI ("http://localhost/5"));
	var stack  = new Queue<Value?> ();

	assert (route.match (req, stack));
	assert (router == route.router);
}

/**
 * @since 0.1
 */
public void test_route_from_rule () {
	var route  = new Route.from_rule (new Router (), "GET", "<int:id>", (req, res) => {});
	var request = new Request.with_uri (new Soup.URI ("http://localhost/5"));
	var stack  = new Queue<Value?> ();

	assert (route.match (request, stack));
	assert (request.params != null);
	assert (request.params["id"] == "5");
	assert ("5" == stack.pop_tail ().get_string ());
}

/**
 * @since 0.1
 */
public void test_route_from_rule_null () {
	var route  = new Route.from_rule (new Router (), "GET", null, (req, res) => {});
	var request = new Request.with_uri (new Soup.URI ("http://localhost/5"));
	var stack  = new Queue<Value?> ();

	assert (route.match (request, stack));
	assert (request.params != null);
	assert (request.params.contains ("path"));
	assert ("5" == request.params["path"]);
	assert ("5" == stack.pop_tail ().get_string ());
}

/**
 * @since 0.1
 */
public static void test_route_from_rule_null_matches_empty_path () {
	var route  = new Route.from_rule (new Router (), "GET", null, (req, res) => {});
	var request = new Request.with_uri (new Soup.URI ("http://localhost/"));
	var stack  = new Queue<Value?> ();

	assert (route.match (request, stack));
	assert ("" == request.params["path"]);
	assert ("" == stack.pop_tail ().get_string ());
}

/**
 * @since 0.1
 */
public void test_route_from_rule_any () {
	var route  = new Route.from_rule (new Router (), "GET", "<any:id>", (req, res) => {});
	var request = new Request.with_uri (new Soup.URI ("http://localhost/5"));
	var stack  = new Queue<Value?> ();

	assert (route.match (request, stack));

	assert (request.params != null);
	assert (request.params["id"] == "5");
	assert ("5" == stack.pop_tail ().get_string ());
}

/**
 * @since 0.1
 */
public void test_route_from_rule_without_captures () {
	var route  = new Route.from_rule (new Router (), "GET", "", (req, res) => {});
	var req    = new Request.with_uri (new Soup.URI ("http://localhost/"));
	var stack  = new Queue<Value?> ();

	assert (req.params == null);

	var matches = route.match (req, stack);

	// ensure params are still null if there is no captures
	assert (matches);
	assert (req.params == null);
	assert (stack.is_empty ());
}

/**
 * @since 0.1
 */
public void test_route_from_rule_undefined_type () {
	var route  = new Route.from_rule (new Router (), "GET", "<uint:unknown_type>", (req, res) => {});
}

/**
 * @since 0.1
 */
public void test_route_from_regex () {
	var route  = new Route.from_regex (new Router (), "GET", /(?<id>\d+)/, (req, res) => {});
	var req    = new Request.with_uri (new Soup.URI ("http://localhost/5"));
	var stack  = new Queue<Value?> ();

	assert (req.params == null);

	var matches = route.match (req, stack);

	assert (matches);
	assert (req.params != null);
	assert (req.params["id"] == "5");
	assert ("5" == stack.pop_tail ().get_string ());
}

/**
 * @since 0.2
 */
public void test_route_from_regex_multiple_captures () {
	var route  = new Route.from_regex (new Router (), "GET", /(?<action>\w+)\/(?<id>\d+)/, (req, res) => {});
	var req    = new Request.with_uri (new Soup.URI ("http://localhost/user/5"));
	var stack  = new Queue<Value?> ();

	assert (req.params == null);

	var matches = route.match (req, stack);

	assert (matches);
	assert (req.params != null);

	assert ("action" in req.params);
	assert ("id" in req.params);

	assert ("user" == req.params["action"]);
	assert ("5" == req.params["id"]);

	assert ("5" == stack.pop_tail ().get_string ());
	assert ("user" == stack.pop_tail ().get_string ());
}

/**
 * @since 0.1
 */
public void test_route_from_regex_scoped () {
	var router = new Router ();

	router.scopes.push_tail ("test");

	var route  = new Route.from_regex (router, "GET", /(?<id>\d+)/, (req, res) => {});
	var req    = new Request.with_uri (new Soup.URI ("http://localhost/test/5"));
	var stack  = new Queue<Value?> ();

	assert (req.params == null);

	var matches = route.match (req, stack);

	assert (matches);
	assert (req.params != null);
	assert (req.params["id"] == "5");
	assert ("5" == stack.pop_tail ().get_string ());
}

/**
 * @since 0.1
 */
public void test_route_from_regex_without_captures () {
	var route  = new Route.from_regex (new Router (), "GET", /.*/, (req, res) => {});
	var req    = new Request.with_uri (new Soup.URI ("http://localhost/"));
	var stack  = new Queue<Value?> ();

	var matches = route.match (req, stack);

	// ensure params are still null if there is no captures
	assert (route.match (req, stack));
	assert (req.params == null);
	assert (stack.is_empty ());
}

/**
 * @since 0.1
 */
public void test_route_match () {
	var route  = new Route.from_rule (new Router (), "GET", "<int:id>", (req, res) => {});
	var req    = new Request.with_uri (new Soup.URI ("http://localhost/5"));
	var stack  = new Queue<Value?> ();

	assert (req.params == null);

	var matches = route.match (req, stack);

	assert (matches);
	assert (req.params != null);
	assert (req.params.contains ("id"));
	assert ("5" == stack.pop_tail ().get_string ());
}

/**
 * @since 0.1
 */
public void test_route_match_not_matching () {
	var route  = new Route.from_rule (new Router (), "GET", "<int:id>", (req, res) => {});
	var req    = new Request.with_uri (new Soup.URI ("http://localhost/home"));
	var stack  = new Queue<Value?> ();

	// no match and params remains null
	assert (route.match (req, stack) == false);
	assert (req.params == null);
	assert (stack.is_empty ());
}

/**
 * @since 0.1
 */
public void test_route_fire () {
	var setted = false;
	var route = new Route.from_rule (new Router (), "GET", "<int:id>", (req, res) => {
		setted = true;
	});
	var req   = new Request.with_uri (new Soup.URI ("http://localhost/home"));
	var res   = new Response (req, 200);
	var stack  = new Queue<Value?> ();

	assert (setted == false);

	route.fire (req, res, () => {}, null);

	assert (setted);
}
