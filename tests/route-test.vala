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
public void test_route () {
	Route route  = {"GET", (req) => { return true; }, (req, res) => {}};
	var req    = new Request.with_uri (new Soup.URI ("http://localhost/5"));
	var stack  = new Queue<Value?> ();

	assert (route.match (req, stack));
}

/**
 * @since 0.1
 */
public void test_route_from_rule () {
	var router = new Router ();
	var route  = router.get ("<int:id>", (req, res) => {}).node.data;
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
	var router = new Router ();
	var route  = router.get (null, (req, res) => {}).node.data;
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
	var router = new Router ();
	var route  = router.get (null, (req, res) => {}).node.data;
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
	var router = new Router ();
	var route  = router.get ("<any:id>", (req, res) => {}).node.data;
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
	var router = new Router ();
	var route  = router.get ("", (req, res) => {}).node.data;
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
	var router = new Router ();
	router.get ("<uint:unknown_type>", (req, res) => {});
}

/**
 * @since 0.1
 */
public void test_route_from_regex () {
	var router = new Router ();
	var route  = router.regex ("GET", /(?<id>\d+)/, (req, res) => {}).node.data;
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
	var router = new Router ();
	var route  = router.regex ("GET", /(?<action>\w+)\/(?<id>\d+)/, (req, res) => {}).node.data;
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

	var route  = router.regex ("GET", /(?<id>\d+)/, (req, res) => {}).node.data;
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
	var router = new Router ();
	var route  = router.regex ("GET", /.*/, (req, res) => {}).node.data;
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
	var router = new Router ();
	var route  = router.get ("<int:id>", (req, res) => {}).node.data;
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
	var router = new Router ();
	var route  = router.get ("<int:id>", (req, res) => {}).node.data;
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
	var router = new Router ();
	var route = router.get ("<int:id>", (req, res) => {
		setted = true;
	}).node.data;
	var req   = new Request.with_uri (new Soup.URI ("http://localhost/home"));
	var res   = new Response (req, 200);
	var stack  = new Queue<Value?> ();

	assert (setted == false);

	route.fire (req, res, () => {}, null);

	assert (setted);
}
