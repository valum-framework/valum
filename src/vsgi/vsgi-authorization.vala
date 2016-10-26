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
 * Hold the state of an 'Authorization' header and provide means to challenge
 * it against a password.
 */
[Version (since = "0.3")]
public abstract class VSGI.Authorization : Object {

	[Version (since = "0.3")]
	public string username { get; construct; }

	/**
	 * Challenge the credentials against a provided password.
	 *
	 * @return 'true' if the password corresponds, 'false' otherwise
	 */
	[Version (since = "0.3")]
	public abstract bool challenge_with_password (string password);

	/**
	 * Produce a 'Authorization' header for this.
	 *
	 * @return an 'Authorization' header value
	 */
	[Version (since = "0.3")]
	public abstract string to_authorization_header ();
}
