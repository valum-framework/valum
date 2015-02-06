/**
 * Builds test suites and launch the GLib test framework.
 */
public int main (string[] args) {

	Test.init (ref args);

	Test.add_func ("/router", test_router);
	Test.add_func ("/router/custom_method", test_router_custom_method);
	Test.add_func ("/router/scope", test_router_scope);
	Test.add_func ("/router/redirection", test_router_redirection);
	Test.add_func ("/router/method_not_allowed", test_router_method_not_allowed);

	Test.add_func ("/route", test_route);
	Test.add_func ("/route/from_rule", test_route_from_rule);
	Test.add_func ("/route/from_rule/any", test_route_from_rule_any);
	Test.add_func ("/route/from_rule/without_captures", test_route_from_rule_without_captures);
	Test.add_func ("/route/from_regex", test_route_from_regex);
	Test.add_func ("/route/from_regex/scoped", test_route_from_regex_scoped);
	Test.add_func ("/route/from_regex/without_captures", test_route_from_regex_without_captures);
	Test.add_func ("/route/match", test_route_match);
	Test.add_func ("/route/match/not_matching", test_route_match_not_matching);
	Test.add_func ("/route/fire", test_route_match_not_matching);

	Test.add_func ("/view/push_string", test_view_push_string);
	Test.add_func ("/view/push_int", test_view_push_int);
	Test.add_func ("/view/push_float", test_view_push_float);

	Test.add_func ("/view/push_strings", test_view_push_strings);
	Test.add_func ("/view/push_ints", test_view_push_ints);
	Test.add_func ("/view/push_floats", test_view_push_floats);

	Test.add_func ("/view/push_collection/strings", test_view_push_collection_strings);
	Test.add_func ("/view/push_collection/ints", test_view_push_collection_ints);
	Test.add_func ("/view/push_collection/floats", test_view_push_collection_floats);

	return Test.run ();
}
