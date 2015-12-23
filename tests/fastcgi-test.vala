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

using VSGI.FastCGI;

/**
 * @since 0.2
 */
public static void test_vsgi_fastcgi_request () {
	string[] environment = {
		"PATH_INFO=/",
		"REQUEST_METHOD=GET",
		"REQUEST_URI=/",
		"SERVER_NAME=0.0.0.0",
		"SERVER_PORT=3003",
		"HTTP_HOST=example.com"
	};

	var connection = new VSGI.Test.Connection ();
	var request    = new Request (connection, environment);

	assert (Soup.HTTPVersion.@1_0 == request.http_version);
	assert ("GET" == request.method);
	assert ("0.0.0.0" == request.uri.get_host ());
	assert (3003 == request.uri.get_port ());
	assert (null == request.query);
	assert (null == request.params);
	assert ("example.com" == request.headers.get_one ("Host"));
	assert (connection.input_stream == request.body);
}

/**
 * @since 0.2
 */
public static void test_vsgi_fastcgi_request_https_on () {
	string[] environment = {
		"PATH_INFO=/",
		"REQUEST_METHOD=GET",
		"REQUEST_URI=/",
		"SERVER_NAME=0.0.0.0",
		"SERVER_PORT=3003",
		"HTTPS=on"
	};

	var connection = new VSGI.Test.Connection ();
	var request    = new Request (connection, environment);

	assert ("https" == request.uri.scheme);
}

/**
 * @since 0.2
 */
public static void test_vsgi_fastcgi_request_uri_with_query () {
	string[] environment = {
		"PATH_INFO=/",
		"REQUEST_METHOD=GET",
		"REQUEST_URI=/",
		"SERVER_NAME=0.0.0.0",
		"SERVER_PORT=3003",
		"REQUEST_URI=/home?a=b"
	};

	var connection = new VSGI.Test.Connection ();
	var request    = new Request (connection, environment);

	assert ("/home" == request.uri.path);
}

/**
 * @since 0.2
 */
public static void test_vsgi_fastcgi_response () {
	string[] environment = {
		"PATH_INFO=/",
		"REQUEST_METHOD=GET",
		"REQUEST_URI=/",
		"SERVER_NAME=0.0.0.0",
		"SERVER_PORT=3003"
	};

	var connection = new VSGI.Test.Connection ();
	var request    = new Request (connection, environment);
	var response   = new Response (request);

	assert (request == response.request);
	assert (!response.head_written);
	assert (connection.output_stream == response.body);
}
