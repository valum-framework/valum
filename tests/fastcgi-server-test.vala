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

public int main (string[] args) {
	Test.init (ref args);

	Test.add_func ("/fastcgi/server/port", () => {
		var server = Server.@new ("fastcgi");

		var options = new VariantBuilder (new VariantType ("a{sv}"));

		options.add ("{sv}", "port", new Variant.@int32 (3003));

		try {
			server.listen (options.end ());
		} catch (Error err) {
			assert_not_reached ();
		}

		assert (1 == server.uris.length ());
		assert ("fcgi://0.0.0.0:3003/" == server.uris.data.to_string (false));
	});

	Test.add_func ("/fastcgi/server/socket", () => {
		var server = Server.@new ("fastcgi");

		var options = new VariantBuilder (new VariantType ("a{sv}"));

		options.add ("{sv}", "socket", new Variant.bytestring ("some-socket.sock"));

		try {
			server.listen (options.end ());
		} catch (Error err) {
			assert_not_reached ();
		} finally {
			FileUtils.unlink ("some-socket.sock");
		}

		assert (1 == server.uris.length ());
		assert ("fcgi+unix://some-socket.sock/" == server.uris.data.to_string (false));
	});

	return Test.run ();
}
