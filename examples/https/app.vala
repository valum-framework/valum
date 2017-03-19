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

using Valum;
using Valum.ContentNegotiation;
using VSGI;

public int main (string[] args) {
	var app = new Router ();

	app.use (basic ());
	app.use (accept ("text/plain"));

	app.get ("/", (req, res) => {
		return res.expand_utf8 ("Hello world!");
	});

	TlsCertificate tls_certificate;
	try {
		tls_certificate = new TlsCertificate.from_files ("tests/data/http-server/cert.pem",
		                                                 "tests/data/http-server/key.pem");
	} catch (Error err) {
		critical (err.message);
		return 1;
	}

	return Server.@new ("http", handler: app, https: true, tls_certificate: tls_certificate).run (args);
}
