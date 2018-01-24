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

	return Test.run ();
}
