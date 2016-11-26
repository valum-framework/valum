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
using VSGI;

/**
 * @since 0.1
 */
public void test_route () {
	var route   = new MatcherRoute (Method.GET, (req) => { return true; }, (req, res) => { return true; });
	var req     = new Request.with_uri (new Soup.URI ("http://localhost/5"));
	var context = new Context ();

	assert (route.match (req, context));
}

/**
 * @since 0.1
 */
public void test_route_from_rule () {
	try {
		var route   = new RuleRoute (Method.GET, "/<id>", new HashTable<string, Regex> (str_hash, str_equal), (req, res) => { return true; });
		var request = new Request.with_uri (new Soup.URI ("http://localhost/5"));
		var context = new Context ();

		message (route.rule);
		assert ("/<id>" == route.rule);
		assert ("^/(?<id>\\w+)$" == route.regex.get_pattern ());
		assert (RegexCompileFlags.OPTIMIZE in route.regex.get_compile_flags ());
		assert (route.match (request, context));
		assert ("5" == context["id"].get_string ());
	} catch (RegexError err) {
		assert_not_reached ();
	}
}

/**
 * @since 0.1
 */
public void test_route_from_rule_without_captures () {
	try {
		var route   = new RuleRoute (Method.GET, "/", new HashTable<string, Regex> (str_hash, str_equal), (req, res) => { return true; });
		var req     = new Request.with_uri (new Soup.URI ("http://localhost/"));
		var context = new Context ();

		var matches = route.match (req, context);

		// ensure params are still null if there is no captures
		assert (matches);
	} catch (RegexError err) {
		assert_not_reached ();
	}
}

/**
 * @since 0.1
 */
public void test_route_from_rule_undefined_type () {
	try {
		new RuleRoute (Method.GET,
		               "/<uint:unknown_type>",
		               new HashTable<string, Regex> (str_hash, str_equal),
		               (req, res) => { return true; });
		assert_not_reached ();
	} catch (RegexError err) {
		assert (err is RegexError.COMPILE);
	}
}

public void test_route_from_rule_group () {
	try {
		var route = new RuleRoute (Method.GET, "/(<id>)?", new HashTable<string, Regex> (str_hash, str_equal), (req, res) => { return true; });

		assert (route.match (new Request.with_uri (new Soup.URI ("http://127.0.0.1:3003/5")), new Context ()));

		var ctx = new Context ();
		assert (route.match (new Request.with_uri (new Soup.URI ("http://127.0.0.1:3003/")), ctx));

		assert (!ctx.contains ("id"));

	} catch (RegexError err) {
		message (err.message);
		assert_not_reached ();
	}
}

/**
 * @since 0.3
 */
public void test_route_from_rule_wildcard () {
	try {
		var route = new RuleRoute (Method.GET, "/test/*", new HashTable<string, Regex> (str_hash, str_equal), (req, res) => { return true; });

		assert (route.match (new Request.with_uri (new Soup.URI ("http://127.0.0.1:3003/test/")), new Context ()));
		assert (route.match (new Request.with_uri (new Soup.URI ("http://127.0.0.1:3003/test/asdf")), new Context ()));

	} catch (RegexError err) {
		assert_not_reached ();
	}
}

/**
 * @since 0.3
 */
public void test_route_from_rule_optional () {
	try {
		var route = new RuleRoute (Method.GET, "/test/?", new HashTable<string, Regex> (str_hash, str_equal), (req, res) => { return true; });

		assert (route.match (new Request.with_uri (new Soup.URI ("http://127.0.0.1:3003/test")), new Context ()));
		assert (route.match (new Request.with_uri (new Soup.URI ("http://127.0.0.1:3003/test/")), new Context ()));

	} catch (RegexError err) {
		assert_not_reached ();
	}
}

/**
 * @since 0.1
 */
public void test_route_from_regex () {
	var route   = new RegexRoute (Method.GET, /\/(?<id>\d+)/, (req, res) => { return true; });
	var req     = new Request.with_uri (new Soup.URI ("http://localhost/5"));
	var context = new Context ();

	assert ("\\/(?<id>\\d+)" == route.regex.get_pattern ());

	var matches = route.match (req, context);

	assert (matches);
	assert ("5" == context["id"].get_string ());
}

/**
 * @since 0.2
 */
public void test_route_from_regex_multiple_captures () {
	var route   = new RegexRoute (Method.GET, /\/(?<action>\w+)\/(?<id>\d+)/, (req, res) => { return true; });
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
public void test_route_from_regex_without_captures () {
	var route   = new RegexRoute (Method.GET, /\/.*/, (req, res) => { return true; });
	var req     = new Request.with_uri (new Soup.URI ("http://localhost/"));
	var context = new Context ();

	assert (route.match (req, context));

	// ensure params are still null if there is no captures
	assert (route.match (req, context));
}

/**
 * @since 0.1
 */
public void test_route_match () {
	try {
		var route   = new RuleRoute (Method.GET, "/<id>", new HashTable<string, Regex> (str_hash, str_equal), (req, res) => { return true; });
		var req     = new Request.with_uri (new Soup.URI ("http://localhost/5"));
		var context = new Context ();

		var matches = route.match (req, context);

		assert (matches);
		assert (context.contains ("id"));
		assert ("5" == context["id"].get_string ());
	} catch (RegexError err) {
		assert_not_reached ();
	}
}

/**
 * @since 0.1
 */
public void test_route_match_not_matching () {
	try {
		var types   = new HashTable<string, Regex> (str_hash, str_equal);
		types["int"] = /\d+/;
		var route   = new RuleRoute (Method.GET, "/<int:id>", types, (req, res) => { return true; });
		var req     = new Request.with_uri (new Soup.URI ("http://localhost/home"));
		var context = new Context ();

		// no match and params remains null
		assert (route.match (req, context) == false);
	} catch (RegexError err) {
		assert_not_reached ();
	}
}

/**
 * @since 0.1
 */
public void test_route_fire () {
	try {
		var setted = false;
		var route = new RuleRoute (Method.GET, "/<id>",  new HashTable<string, Regex> (str_hash, str_equal), (req, res) => {
			setted = true;
			return true;
		});

		var req     = new Request.with_uri (new Soup.URI ("http://localhost/home"));
		var res     = new Response (req);
		var context = new Context ();

		assert (setted == false);

		try {
			route.fire (req, res, () => { return true; }, context);
		} catch (Error err) {
			assert_not_reached ();
		}

		assert (setted);
	} catch (RegexError err) {
		assert_not_reached ();
	}
}
