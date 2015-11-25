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

using VSGI.SCGI;

/**
 * @since 0.2
 */
public void test_vsgi_scgi_request_with_request_uri () {
	var environment   = new HashTable<string, string> (str_hash, str_equal);

	environment["REQUEST_METHOD"] = "GET";
	environment["SERVER_NAME"]    = "0.0.0.0";
	environment["SERVER_PORT"]    = "3003";
	environment["REQUEST_URI"]    = "/home?a=b";

	var connection = new VSGI.Test.Connection ();
	var request    = new Request (connection, new DataInputStream (connection.input_stream), environment);

	assert ("/home" == request.uri.path);
}
