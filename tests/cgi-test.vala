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

using VSGI;

/**
 * @since 0.2
 */
public void test_vsgi_cgi_request () {
	string[] environment = {
		"PATH_INFO=/",
		"QUERY_STRING=a=b",
		"REMOTE_USER=root",
		"REQUEST_METHOD=GET",
		"SERVER_NAME=0.0.0.0",
		"SERVER_PORT=3003",
		"HTTP_HOST=example.com"
	};

	var req_body = new MemoryInputStream ();
	var request  = new Request.from_cgi_environment (null, environment, req_body);

	assert (Soup.HTTPVersion.@1_0 == request.http_version);
	assert ("CGI/1.1" == request.gateway_interface);
	assert ("GET" == request.method);
	assert ("root" == request.uri.get_user ());
	assert ("0.0.0.0" == request.uri.get_host ());
	assert ("a=b" == request.uri.get_query ());
	assert ("http://root@0.0.0.0:3003/?a=b" == request.uri.to_string (false));
	assert (request.query.contains ("a"));
	assert ("b" == request.query["a"]);
	assert (3003 == request.uri.get_port ());
	assert ("example.com" == request.headers.get_one ("Host"));
	assert (req_body != request.body);
}

/**
 * @since 0.3
 */
public void test_vsgi_cgi_request_gateway_interface () {
	var request = new Request.from_cgi_environment (null, {"GATEWAY_INTERFACE=CGI/1.0"});

	assert ("CGI/1.0" == request.gateway_interface);
}

/**
 * @since 0.3
 */
public void test_vsgi_cgi_request_content_type () {
	var request = new Request.from_cgi_environment (null, {"CONTENT_TYPE=text/html; charset=UTF-8"});

	HashTable<string, string> @params;
	assert ("text/html" == request.headers.get_content_type (out @params));
	assert ("UTF-8" == @params["charset"]);
}

/**
 * @since 0.3
 */
public void test_vsgi_cgi_request_content_length () {
	var request = new Request.from_cgi_environment (null, {"CONTENT_LENGTH=12"});

	assert (12 == request.headers.get_content_length ());
}

/**
 * @since 0.3
 */
public void test_vsgi_cgi_request_content_length_malformed () {
	var request = new Request.from_cgi_environment (null, {"CONTENT_LENGTH=12a"});

	assert (0 == request.headers.get_content_length ());
}

/**
 * @since 0.2
 */
public void test_vsgi_cgi_request_missing_path_info () {
	string[] environment = {};
	var request     = new Request.from_cgi_environment (null, environment);

	assert ("/" == request.uri.get_path ());
}

/**
 * @since 0.2
 */
public void test_vsgi_cgi_request_http_1_1 () {
	string[] environment = {"SERVER_PROTOCOL=HTTP/1.1"};

	var request = new Request.from_cgi_environment (null, environment);

	assert (Soup.HTTPVersion.@1_1 == request.http_version);
}

/**
 * @since 0.2.4
 */
public void test_vsgi_cgi_request_https_detection () {
	string[] environment = {"PATH_TRANSLATED=https://example.com:80/"};

	var request = new Request.from_cgi_environment (null, environment);

	assert ("https" == request.uri.scheme);
}

/**
 * @since 0.2
 */
public void test_vsgi_cgi_request_https_on () {
	string[] environment = {
		"PATH_INFO=/",
		"REQUEST_METHOD=GET",
		"REQUEST_URI=/",
		"SERVER_NAME=0.0.0.0",
		"SERVER_PORT=3003",
		"HTTPS=on"
	};

	var request    = new Request.from_cgi_environment (null, environment);

	assert ("https" == request.uri.scheme);
}

/**
 * @since 0.2
 */
public void test_vsgi_cgi_request_request_uri () {
	string[] environment = {
		"REQUEST_METHOD=GET",
		"SERVER_NAME=0.0.0.0",
		"SERVER_PORT=3003",
		"QUERY_STRING=a=b",
		"REQUEST_URI=/home?a=b"
	};

	var request    = new Request.from_cgi_environment (null, environment);

	assert ("GET" == request.method);
	assert ("/home" == request.uri.path);
	assert ("a" in request.query);
	assert ("b" == request.query["a"]);
}

/**
 * @since 0.2
 */
public void test_vsgi_cgi_request_uri_with_query () {
	string[] environment = {
		"PATH_INFO=/home",
		"REQUEST_METHOD=GET",
		"SERVER_NAME=0.0.0.0",
		"SERVER_PORT=3003",
		"REQUEST_URI=/home?a=b"
	};

	var request    = new Request.from_cgi_environment (null, environment);

	assert ("/home" == request.uri.path);
}

/**
 * @since 0.2
 */
public void test_vsgi_cgi_response () {
	string[] environment = {};
	var request     = new Request.from_cgi_environment (null, environment);
	var response    = new Response (request);

	assert (Soup.Status.OK == response.status);

	size_t bytes_written;
	try {
		response.write_head (out bytes_written);
	} catch (IOError err) {
		assert_not_reached ();
	}
	assert (18 == bytes_written);
	assert (response.head_written);
	assert ("200 OK" == response.headers.get_one ("Status"));
}
