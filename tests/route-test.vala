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
	var router  = new Router ();
	var route   = new Route (router, "GET", (req) => { return true; }, (req, res) => {});
	var req     = new Request.with_uri (new Soup.URI ("http://localhost/5"));
	var context = new Context ();

	assert (route.match (req, context));
	assert (router == route.router);
}

/**
 * @since 0.1
 */
public void test_route_from_rule () {
	var route   = new Route.from_rule (new Router (), "GET", "<int:id>", (req, res) => {});
	var request = new Request.with_uri (new Soup.URI ("http://localhost/5"));
	var context = new Context ();

	assert (route.match (request, context));
	assert ("5" == context["id"].get_string ());
}

/**
 * @since 0.1
 */
public void test_route_from_rule_null () {
	var route   = new Route.from_rule (new Router (), "GET", null, (req, res) => {});
	var request = new Request.with_uri (new Soup.URI ("http://localhost/5"));
	var context = new Context ();

	assert (route.match (request, context));
	assert (context.contains ("path"));
	assert ("5" == context["path"].get_string ());
}

/**
 * @since 0.1
 */
public static void test_route_from_rule_null_matches_empty_path () {
	var route   = new Route.from_rule (new Router (), "GET", null, (req, res) => {});
	var request = new Request.with_uri (new Soup.URI ("http://localhost/"));
	var context = new Context ();

	assert (route.match (request, context));
	assert ("" == context["path"].get_string ());
}

/**
 * @since 0.1
 */
public void test_route_from_rule_any () {
	var route   = new Route.from_rule (new Router (), "GET", "<any:id>", (req, res) => {});
	var request = new Request.with_uri (new Soup.URI ("http://localhost/5"));
	var context = new Context ();

	assert (route.match (request, context));

	assert ("5" == context["id"].get_string ());
}

/**
 * @since 0.1
 */
public void test_route_from_rule_without_captures () {
	var route   = new Route.from_rule (new Router (), "GET", "", (req, res) => {});
	var req     = new Request.with_uri (new Soup.URI ("http://localhost/"));
	var context = new Context ();

	var matches = route.match (req, context);

	// ensure params are still null if there is no captures
	assert (matches);
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
	var route   = new Route.from_regex (new Router (), "GET", /(?<id>\d+)/, (req, res) => {});
	var req     = new Request.with_uri (new Soup.URI ("http://localhost/5"));
	var context = new Context ();

	var matches = route.match (req, context);

	assert (matches);
	assert ("5" == context["id"].get_string ());
}

/**
 * @since 0.2
 */
public void test_route_from_regex_multiple_captures () {
	var route   = new Route.from_regex (new Router (), "GET", /(?<action>\w+)\/(?<id>\d+)/, (req, res) => {});
	var req     = new Request.with_uri (new Soup.URI ("http://localhost/user/5"));
	var context = new Context ();

	assert (route.match (req, context));

	assert ("action" in context);
	assert ("id" in context);

	assert ("user" == context["action"].get_string ());
	assert ("5" == context["id"].get_string ());
}

/**
 * @since 0.1
 */
public void test_route_from_regex_scoped () {
	var router = new Router ();

	router.scopes.push_tail ("test");

	var route   = new Route.from_regex (router, "GET", /(?<id>\d+)/, (req, res) => {});
	var req     = new Request.with_uri (new Soup.URI ("http://localhost/test/5"));
	var context = new Context ();

	assert (route.match (req, context));

	assert ("5" == context["id"].get_string ());
}

/**
 * @since 0.1
 */
public void test_route_from_regex_without_captures () {
	var route   = new Route.from_regex (new Router (), "GET", /.*/, (req, res) => {});
	var req     = new Request.with_uri (new Soup.URI ("http://localhost/"));
	var context = new Context ();

	var matches = route.match (req, context);

	// ensure params are still null if there is no captures
	assert (route.match (req, context));
}

/**
 * @since 0.1
 */
public void test_route_match () {
	var route   = new Route.from_rule (new Router (), "GET", "<int:id>", (req, res) => {});
	var req     = new Request.with_uri (new Soup.URI ("http://localhost/5"));
	var context = new Context ();

	var matches = route.match (req, context);

	assert (matches);
	assert (context.contains ("id"));
	assert ("5" == context["id"].get_string ());
}

/**
 * @since 0.1
 */
public void test_route_match_not_matching () {
	var route   = new Route.from_rule (new Router (), "GET", "<int:id>", (req, res) => {});
	var req     = new Request.with_uri (new Soup.URI ("http://localhost/home"));
	var context = new Context ();

	// no match and params remains null
	assert (route.match (req, context) == false);
}

/**
 * @since 0.1
 */
public void test_route_fire () {
	var setted = false;
	var route = new Route.from_rule (new Router (), "GET", "<int:id>", (req, res) => {
		setted = true;
	});

	var req     = new Request.with_uri (new Soup.URI ("http://localhost/home"));
	var res     = new Response (req);
	var context = new Context ();

	assert (setted == false);

	route.fire (req, res, () => {}, null);

	assert (setted);
}
