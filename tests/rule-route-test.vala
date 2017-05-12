using GLib;
using Valum;

public int main (string[] args) {
	Test.init (ref args);

	Test.add_func ("/rule_route/to_url_from_hash", () => {
		RuleRoute route;
		try {
			route = new RuleRoute (Method.GET, "/hello/<i>", new HashTable<string, Regex> (str_hash, str_equal), () => { return true; });
		} catch (RegexError err) {
			assert_not_reached ();
		}

		var @params = new HashTable<string, string> (str_hash, str_equal);
		@params["i"] = "5";
		assert ("/hello/5" == route.to_url_from_hash (@params));
	});

	Test.add_func ("/rule_route/to_url", () => {
		RuleRoute route;
		try {
			route = new RuleRoute (Method.GET, "/hello/<i>", new HashTable<string, Regex> (str_hash, str_equal), () => { return true; });
		} catch (RegexError err) {
			assert_not_reached ();
		}

		assert ("/hello/5" == route.to_url ("i", "5"));
	});

	Test.add_func ("/rule_route/to_url/exclude_rule_specific_characters", () => {
		RuleRoute route;
		try {
			route = new RuleRoute (Method.GET, "/hello/(a)/*b?", new HashTable<string, Regex> (str_hash, str_equal), () => { return true; });
		} catch (RegexError err) {
			assert_not_reached ();
		}

		assert ("/hello/a/b" == route.to_url ());
	});

	Test.add_func ("/rule_route/to_url/optional", () => {
		RuleRoute route;
		try {
			route = new RuleRoute (Method.GET, "/hello/<i>?", new HashTable<string, Regex> (str_hash, str_equal), () => { return true; });
		} catch (RegexError err) {
			assert_not_reached ();
		}

		assert ("/hello/" == route.to_url ());
	});

	Test.add_func ("/rule_route/to_url/error_on_missing_parameter", () => {
		Test.trap_subprocess ("/rule_route/to_url/error_on_missing_parameter/subprocess", 0, 0);
		Test.trap_assert_failed ();
	});

	Test.add_func ("/rule_route/to_url/error_on_missing_parameter/subprocess", () => {
		RuleRoute route;
		try {
			route = new RuleRoute (Method.GET, "/hello/<i>", new HashTable<string, Regex> (str_hash, str_equal), () => { return true; });
		} catch (RegexError err) {
			assert_not_reached ();
		}
		route.to_url ();
	});

	Test.add_func ("/rule_route/to_url/error_on_missing_value", () => {
		Test.trap_subprocess ("/rule_route/to_url/error_on_missing_value/subprocess", 0, 0);
		Test.trap_assert_failed ();
	});

	Test.add_func ("/rule_route/to_url/error_on_missing_value/subprocess", () => {
		RuleRoute route;
		try {
			route = new RuleRoute (Method.GET, "/hello/<i>", new HashTable<string, Regex> (str_hash, str_equal), () => { return true; });
		} catch (RegexError err) {
			assert_not_reached ();
		}
		route.to_url ("i");
	});

	Test.add_func ("/rule_route/to_url/replace_dash_with_underscore", () => {
		RuleRoute route;
		try {
			route = new RuleRoute (Method.GET, "/foo/<some_id>", new HashTable<string, Regex> (str_hash, str_equal), () => { return true; });
		} catch (RegexError err) {
			assert_not_reached ();
		}
		assert ("/foo/5" == route.to_url (some_id: "5"));
	});

	return Test.run ();
}
