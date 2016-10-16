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

using GLib.Unix;
using VSGI;

public int main (string[] args) {
	Test.init (ref args);

	Test.add_func ("/fastcgi_server/port", () => {
		var server = Server.@new ("fastcgi");
		var port   = (uint16) Random.int_range (1024, 32768);

		try {
			server.listen (new InetSocketAddress (new InetAddress.any (SocketFamily.IPV4), port));
		} catch (Error err) {
			assert_not_reached ();
		}

		assert (1 == server.uris.length ());
		assert ("fcgi://0.0.0.0:%d/".printf (port) == server.uris.data.to_string (false));
	});

	Test.add_func ("/fastcgi_server/socket", () => {
		var server = Server.@new ("fastcgi");

		try {
			server.listen (new UnixSocketAddress ("some-socket.sock"));
		} catch (Error err) {
			assert_not_reached ();
		} finally {
			FileUtils.unlink ("some-socket.sock");
		}

		assert (1 == server.uris.length ());
		assert ("fcgi+unix://some-socket.sock/" == server.uris.data.to_string (false));
	});

	Test.add_func ("/fastcgi_server/multiple_listen", () => {
		var server  = Server.@new ("fastcgi");

		try {
			server.listen (new UnixSocketAddress ("some-socket.sock"));
		} catch (Error err) {
			assert_not_reached ();
		} finally {
			FileUtils.unlink ("some-socket.sock");
		}

		try {
			server.listen (new UnixSocketAddress ("some-socket.sock"));
		} catch (Error err) {
			assert (1 == server.uris.length ());
		} finally {
			FileUtils.unlink ("some-socket.sock");
		}
	});

	return Test.run ();
}
