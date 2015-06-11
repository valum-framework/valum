/**
 * Builds test suites and launch the GLib test framework.
 */
public int main (string[] args) {

	Test.init (ref args);

	Test.add_func ("/router", test_router);
	Test.add_func ("/router/custom_method", test_router_custom_method);
	Test.add_func ("/router/scope", test_router_scope);

	Test.add_func ("/router/informational/switching_protocols", test_router_informational_switching_protocols);
	Test.add_func ("/router/success/created", test_router_success_created);
	Test.add_func ("/router/success/partial_content", test_router_success_partial_content);
	Test.add_func ("/router/redirection", test_router_redirection);
	Test.add_func ("/router/client_error/method_not_allowed", test_router_client_error_method_not_allowed);
	Test.add_func ("/router/client_error/upgrade_required", test_router_client_error_upgrade_required);

	Test.add_func ("/router/method_not_allowed", test_router_method_not_allowed);
	Test.add_func ("/router/method_not_allowed/excludes_request_method",
			       test_router_method_not_allowed_excludes_request_method);
	Test.add_func ("/router/not_found", test_router_not_found);
	Test.add_func ("/router/server_error", test_router_server_error);

	Test.add_func ("/router/get", test_router_get);
	Test.add_func ("/router/post", test_router_post);
	Test.add_func ("/router/put", test_router_put);
	Test.add_func ("/router/delete", test_router_delete);
	Test.add_func ("/router/head", test_router_head);
	Test.add_func ("/router/options", test_router_options);
	Test.add_func ("/router/trace", test_router_trace);
	Test.add_func ("/router/connect", test_router_connect);
	Test.add_func ("/router/patch", test_router_patch);

	Test.add_func ("/router/methods", test_router_methods);
	Test.add_func ("/router/all", test_router_all);

	Test.add_func ("/router/regex", test_router_regex);
	Test.add_func ("/router/matcher", test_router_matcher);

	Test.add_func ("/router/subrouting", test_router_subrouting);

	Test.add_func ("/router/status/propagates_error_message", test_router_status_propagates_error_message);

	Test.add_func ("/router/next", test_router_next);
	Test.add_func ("/router/next/not_found", test_router_next_not_found);
	Test.add_func ("/router/next/propagate_error", test_router_next_propagate_error);
	Test.add_func ("/router/next/propagate_state", test_router_next_propagate_state);
	Test.add_func ("/router/next/replace_propagated_state", test_router_next_replace_propagated_state);

	Test.add_func ("/route", test_route);
	Test.add_func ("/route/from_rule", test_route_from_rule);
	Test.add_func ("/route/from_rule/null", test_route_from_rule_null);
	Test.add_func ("/route/from_rule/null/matches_empty_path", test_route_from_rule_null_matches_empty_path);
	Test.add_func ("/route/from_rule/any", test_route_from_rule_any);
	Test.add_func ("/route/from_rule/without_captures", test_route_from_rule_without_captures);

#if GLIB_2_38
	Test.add_func ("/route/from_rule/undefined_type", () => {
		Test.trap_subprocess ("/route/from_rule/undefined_type/subprocess", 0, 0);
		Test.trap_assert_failed ();
	});

	Test.add_func ("/route/from_rule/undefined_type/subprocess", test_route_from_rule_undefined_type);
#endif

	Test.add_func ("/route/from_regex", test_route_from_regex);
	Test.add_func ("/route/from_regex/scoped", test_route_from_regex_scoped);
	Test.add_func ("/route/from_regex/without_captures", test_route_from_regex_without_captures);
	Test.add_func ("/route/match", test_route_match);
	Test.add_func ("/route/match/not_matching", test_route_match_not_matching);
	Test.add_func ("/route/fire", test_route_match_not_matching);

	Test.add_func ("/view/from_string", test_view_from_string);
	Test.add_func ("/view/from_path", test_view_from_path);
	Test.add_func ("/view/from_stream", test_view_from_stream);

	Test.add_func ("/view/push_string", test_view_push_string);
	Test.add_func ("/view/push_int", test_view_push_int);
	Test.add_func ("/view/push_float", test_view_push_float);

	Test.add_func ("/view/push_strings", test_view_push_strings);
	Test.add_func ("/view/push_ints", test_view_push_ints);
	Test.add_func ("/view/push_floats", test_view_push_floats);

	Test.add_func ("/view/push_collection/strings", test_view_push_collection_strings);
	Test.add_func ("/view/push_collection/ints", test_view_push_collection_ints);
	Test.add_func ("/view/push_collection/floats", test_view_push_collection_floats);
	Test.add_func ("/view/push_collection/unknown_type", test_view_push_collection_unknown_type);

	Test.add_func ("/view/push_map", test_view_push_map);
	Test.add_func ("/view/push_string_map", test_view_push_string_map);
	Test.add_func ("/view/push_int_map", test_view_push_int_map);

	Test.add_func ("/view/push_string_multimap", test_view_push_string_multimap);
	Test.add_func ("/view/push_int_multimap", test_view_push_int_multimap);

	Test.add_func ("/view/push_hashtable", test_view_push_hashtable);
	Test.add_func ("/view/push_string_hashtable", test_view_push_string_hashtable);
	Test.add_func ("/view/push_int_hashtable", test_view_push_int_hashtable);

	Test.add_func ("/view/push_value/null", test_view_push_value_null);
	Test.add_func ("/view/push_value/string", test_view_push_value_string);
	Test.add_func ("/view/push_value/unknown_type", test_view_push_value_unknown_type);

	return Test.run ();
}
