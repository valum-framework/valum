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

using VSGI.Soup;

/**
 * @since 0.2
 */
public static void test_vsgi_soup_request () {
	var message      = new Soup.Message ("GET", "http://0.0.0.0:3003/");

	var connection = new VSGI.Test.Connection ();
	var request    = new Request (connection, message, null);

	assert (message == request.message);
	assert (Soup.HTTPVersion.@1_1 == request.http_version);
	assert ("GET" == request.method);
	assert ("0.0.0.0" == request.uri.get_host ());
	assert (3003 == request.uri.get_port ());
	assert (null == request.query);
	assert (message.request_headers == request.headers);
}

/**
 * @since 0.2
 */
public static void test_vsgi_soup_response () {
	var message       = new Soup.Message ("GET", "http://0.0.0.0:3003/");

	var connection = new VSGI.Test.Connection ();
	var request    = new Request (connection, message, null);
	var response   = new Response (request, message);

	assert (message == request.message);
	assert (request == response.request);
	assert (!response.head_written);
	assert (connection.output_stream == response.body);
}
