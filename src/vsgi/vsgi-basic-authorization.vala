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

/**
 * Hold the state of a basic 'Authorization' header.
 */
[Version (since = "0.3")]
public class VSGI.BasicAuthorization : Authorization {

	[Version (since = "0.3")]
	public string password { get; construct; }

	[Version (since = "0.3")]
	public BasicAuthorization (string username, string password) {
		Object (username: username, password: password);
	}

	public override bool challenge_with_password (string password) {
		return str_const_equal (password, this.password);
	}

	public override string to_authorization_header () {
		return "Basic %s".printf (Base64.encode ((uchar[]) "%s:%s".printf (username, password).to_utf8 ()));
	}
}
