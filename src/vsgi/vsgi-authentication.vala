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
 * Hold the necessary state to challenge and emit authentication headers.
 */
[Version (since = "0.3")]
public abstract class VSGI.Authentication : Object {

	[Version (since = "0.3")]
	public string realm { get; construct set; }

	/**
	 * Indicate the expected charset to use by the user agent to encode username
	 * and password.
	 *
	 * If not specified, 'UTF-8' is assumed.
	 */
	[Version (since = "0.3")]
	public string? charset { get; construct; default = null; }

	/**
	 * Check and extract the fields from an 'Authorization' header.
	 *
	 * @param authorization_header 'Authorization' header value
	 * @param authorization        extracted {@link VSGI.Authorization} object
	 *                             containing the fields from the header
	 *
	 * @return 'true' on success, otherwise 'false' and 'authorization' is set
	 *         to 'null'
	 */
	[Version (since = "0.3")]
	public abstract bool parse_authorization_header (string authorization_header, out Authorization? authorization);

	/**
	 * Produce a 'WWW-Authenticate' (or 'Proxy-Authenticate') header for this.
	 */
	[Version (since = "0.3")]
	public abstract string to_authenticate_header ();
}
