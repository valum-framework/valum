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
using Valum;
using VSGI;

public int main (string[] args) {
	Test.init (ref args);

	Test.add_func ("/authenticate", () => {
		var req = new Request.with_method ("GET", new Soup.URI ("http://localhost/"));
		var res = new Response (req);

		req.headers.replace ("Authorization", "Basic " + Base64.encode ({'t', 'e', 's', 't', ':', '1', '2', '3', '4'}));

		try {
			assert (authenticate (new VSGI.BasicAuthentication ("realm"), (authorization) => {
				return authorization.challenge_with_password ("1234");
			}) (req, res, () => {
				return true;
			}, new Context ()));
		} catch (Error err) {
			assert_not_reached ();
		}
	});

	Test.add_func ("/authenticate/no_authorization_header", () => {
		var req = new Request.with_method ("GET", new Soup.URI ("http://localhost/"));
		var res = new Response (req);

		assert (null == req.headers.get_one ("Authorization"));

		try {
			authenticate (new VSGI.BasicAuthentication ("realm"), (authorization) => {
				return authorization.challenge_with_password ("1234");
			}) (req, res, () => {
				assert_not_reached ();
			}, new Context ());
		} catch (ClientError.UNAUTHORIZED err) {
			assert ("Basic realm=\"realm\"" == err.message);
		} catch (Error err) {
			assert_not_reached ();
		}
	});

	Test.add_func ("/authenticate/malformed_authorization_header", () => {
		var req = new Request.with_method ("GET", new Soup.URI ("http://localhost/"));
		var res = new Response (req);

		req.headers.replace ("Authorization", "Basic");

		try {
			authenticate (new VSGI.BasicAuthentication ("realm"), (authorization) => {
				return authorization.challenge_with_password ("1234");
			}) (req, res, () => {
				assert_not_reached ();
			}, new Context ());
		} catch (ClientError.UNAUTHORIZED err) {
			assert ("Basic realm=\"realm\"" == err.message);
		} catch (Error err) {
			assert_not_reached ();
		}
	});

	Test.add_func ("/authenticate/wrong_credentials", () => {
		var req = new Request.with_method ("GET", new Soup.URI ("http://localhost/"));
		var res = new Response (req);

		req.headers.replace ("Authorization", "Basic " + Base64.encode ({'t', 'e', 's', 't', ':', '1', '2', '3'}));

		try {
			authenticate (new VSGI.BasicAuthentication ("realm"), (authorization) => {
				return authorization.challenge_with_password ("1234");
			}) (req, res, () => {
				assert_not_reached ();
			}, new Context ());
		} catch (ClientError.UNAUTHORIZED err) {
			assert ("Basic realm=\"realm\"" == err.message);
		} catch (Error err) {
			assert_not_reached ();
		}
	});

	return Test.run ();
}
