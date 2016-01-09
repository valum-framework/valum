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

using VSGI.CGI;

/**
 * @since 0.2
 */
public static void test_vsgi_cgi_request () {
	string[] environment = {
		"PATH_INFO=/",
		"QUERY_STRING=a=b",
		"REMOTE_USER=root",
		"REQUEST_METHOD=GET",
		"SERVER_NAME=0.0.0.0",
		"SERVER_PORT=3003",
		"HTTP_HOST=example.com"
	};

	var connection = new VSGI.Test.Connection ();
	var request    = new Request (connection, environment);

	assert (Soup.HTTPVersion.@1_0 == request.http_version);
	assert ("GET" == request.method);
	assert ("root" == request.uri.get_user ());
	assert ("0.0.0.0" == request.uri.get_host ());
	assert ("a=b" == request.uri.get_query ());
	assert ("http://root@0.0.0.0:3003/?a=b" == request.uri.to_string (false));
	assert (request.query.contains ("a"));
	assert ("b" == request.query["a"]);
	assert (3003 == request.uri.get_port ());
	assert ("example.com" == request.headers.get_one ("Host"));
	assert (connection.input_stream == request.body);
}

/**
 * @since 0.2
 */
public static void test_vsgi_cgi_request_missing_path_info () {
	string[] environment = {};
	var connection  = new VSGI.Test.Connection ();
	var request     = new Request (connection, environment);

	assert ("/" == request.uri.get_path ());
}

/**
 * @since 0.2
 */
public void test_vsgi_cgi_request_http_1_1 () {
	var connection  = new VSGI.Test.Connection ();
	string[] environment = {"SERVER_PROTOCOL=HTTP/1.1"};

	var request = new Request (connection, environment);

	assert (Soup.HTTPVersion.@1_1 == request.http_version);
}

/**
 * @since 0.2.4
 */
public void test_vsgi_cgi_request_https_detection () {
	var connection       = new VSGI.Test.Connection ();
	string[] environment = {"PATH_TRANSLATED=https://example.com:80/"};

	var request = new Request (connection, environment);

	assert ("https" == request.uri.scheme);
}

/**
 * @since 0.2
 */
public void test_vsgi_cgi_response () {
	string[] environment = {};
	var connection  = new VSGI.Test.Connection ();
	var request     = new Request (connection, environment);
	var response    = new Response (request);

	assert (Soup.Status.OK == response.status);

	size_t bytes_written;
	response.write_head (out bytes_written);
	assert (18 == bytes_written);
	assert (response.head_written);
}

