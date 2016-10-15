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
using VSGI;

public int main (string[] args) {
	Test.init (ref args);

	Test.add_func ("/http_server/https", () => {
		TlsCertificate tls_certificate;
		try {
			tls_certificate = new TlsCertificate.from_files (Test.get_filename (Test.FileType.DIST, "data", "http-server", "cert.pem"),
			                                                 Test.get_filename (Test.FileType.DIST, "data", "http-server", "key.pem"));
		} catch (Error err) {
			assert_not_reached ();
		}

		var https_server = Server.@new ("http", https: true, tls_certificate: tls_certificate);

		try {
			https_server.listen ();
		} catch (Error err) {
			assert_not_reached ();
		}

		assert ("https" == https_server.uris.data.scheme);
	});

	return Test.run ();
}
