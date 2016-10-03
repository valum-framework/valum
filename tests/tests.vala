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

using GLib;

/**
 * Builds test suites and launch the GLib test framework.
 */
public int main (string[] args) {
	Test.init (ref args);
	Test.bug_base ("https://github.com/valum-framework/valum/issues/%s");

	Test.add_func ("/route", test_route);
	Test.add_func ("/route/from_rule", test_route_from_rule);
	Test.add_func ("/route/from_rule/without_captures", test_route_from_rule_without_captures);
	Test.add_func ("/route/from_rule/undefined_type", test_route_from_rule_undefined_type);
	Test.add_func ("/route/from_rule/group", test_route_from_rule_group);
	Test.add_func ("/route/from_rule/wildcard", test_route_from_rule_wildcard);
	Test.add_func ("/route/from_rule/optional", test_route_from_rule_optional);

	Test.add_func ("/route/from_regex", test_route_from_regex);
	Test.add_func ("/route/from_regex/multiple_captures", test_route_from_regex_multiple_captures);
	Test.add_func ("/route/from_regex/without_captures", test_route_from_regex_without_captures);
	Test.add_func ("/route/match", test_route_match);
	Test.add_func ("/route/match/not_matching", test_route_match_not_matching);
	Test.add_func ("/route/fire", test_route_match_not_matching);

	Test.add_func ("/decode/gzip", test_decode_gzip);
	Test.add_func ("/decode/xgzip", test_decode_xgzip);
	Test.add_func ("/decode/deflate", test_decode_deflate);
	Test.add_func ("/decode/unknown_encoding", test_decode_unknown_encoding);
	Test.add_func ("/decode/forward_remaining_encodings", test_decode_forward_remaining_encodings);

	Test.add_func ("/subdomain", test_subdomain);
	Test.add_func ("/subdomain/joker", test_subdomain_joker);
	Test.add_func ("/subdomain/strict", test_subdomain_strict);
	Test.add_func ("/subdomain/extract", test_subdomain_extract);

	Test.add_func ("/server_sent_events/send", test_server_sent_events_send);
	Test.add_func ("/server_sent_events/send_multiline", test_server_sent_events_send_multiline);
	Test.add_func ("/server_sent_events/skip_on_head", test_server_sent_events_skip_on_head);

	Test.add_func ("/vsgi/cookies/from_request", test_vsgi_cookies_from_request);
	Test.add_func ("/vsgi/cookies/from_response", test_vsgi_cookies_from_response);
	Test.add_func ("/vsgi/cookies/lookup", test_vsgi_cookies_lookup);
	Test.add_func ("/vsgi/cookies/sign", test_vsgi_cookies_sign);
	Test.add_func ("/vsgi/cookies/sign/empty_cookie", test_vsgi_cookies_sign_empty_cookie);
	Test.add_func ("/vsgi/cookies/sign_and_verify", test_vsgi_cookies_sign_and_verify);
	Test.add_func ("/vsgi/cookies/verify", test_vsgi_cookies_verify);
	Test.add_func ("/vsgi/cookies/verify/bad_signature", test_vsgi_cookies_verify_bad_signature);
	Test.add_func ("/vsgi/cookies/verify/too_small_value", test_vsgi_cookies_verify_too_small_value);

	Test.add_func ("/vsgi/cgi/request", test_vsgi_cgi_request);
	Test.add_func ("/vsgi/cgi/request/gateway_interface", test_vsgi_cgi_request_gateway_interface);
	Test.add_func ("/vsgi/cgi/request/content_type", test_vsgi_cgi_request_content_type);
	Test.add_func ("/vsgi/cgi/request/content_length", test_vsgi_cgi_request_content_length);
	Test.add_func ("/vsgi/cgi/request/content_length/malformed", test_vsgi_cgi_request_content_length_malformed);
	Test.add_func ("/vsgi/cgi/request/missing_path_info", test_vsgi_cgi_request_missing_path_info);
	Test.add_func ("/vsgi/cgi/request/http_1_1", test_vsgi_cgi_request_http_1_1);
	Test.add_func ("/vsgi/cgi/request/https_detection", test_vsgi_cgi_request_https_detection);
	Test.add_func ("/vsgi/cgi/request/https_on", test_vsgi_cgi_request_https_on);
	Test.add_func ("/vsgi/cgi/request/request_uri", test_vsgi_cgi_request_request_uri);
	Test.add_func ("/vsgi/cgi/request/uri_with_query", test_vsgi_cgi_request_uri_with_query);

	return Test.run ();
}
