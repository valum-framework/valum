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

	Test.add_func ("/auth/basic", () => {
		var authentication = new BasicAuthentication ("realm");
		assert ("realm" == authentication.realm);
		assert ("Basic realm=\"realm\"" == authentication.to_authenticate_header ());

		Authorization authorization;
		assert (!authentication.parse_authorization_header ("Basic", out authorization));
		assert (!authentication.parse_authorization_header ("Basic " + Base64.encode ({'t', 'e', 's', 't'}), out authorization));
		assert (!authentication.parse_authorization_header ("Digest dGVzdDoxMjM0", out authorization));
		assert (!authentication.parse_authorization_header ("Basic " + Base64.encode ({'t', 'e', 's', 't', ':', 0x7}), out authorization));

		assert (authentication.parse_authorization_header ("Basic dGVzdDoxMjM0", out authorization));

		assert (authorization.challenge_with_password ("1234"));
		assert (!authorization.challenge_with_password ("123"));
		assert ("Basic dGVzdDoxMjM0" == authorization.to_authorization_header ());
	});

	Test.add_func ("/auth/basic/charset", () => {
		var authentication = new BasicAuthentication ("realm", "UTF-8");

		assert ("Basic realm=\"realm\", charset=\"UTF-8\"" == authentication.to_authenticate_header ());

		Authorization authorization;
		assert (authentication.parse_authorization_header ("Basic " + Base64.encode ({'t', 'e', 's', 't', ':', '1', '2', '3', '4'}), out authorization));
		assert (authorization.challenge_with_password ("1234"));
	});

	return Test.run ();
}
