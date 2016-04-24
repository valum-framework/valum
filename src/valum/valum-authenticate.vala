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

namespace Valum {

	/**
	 * Perform the authentication against the credentials source.
	 *
	 * This will typically retreive the password for {@link VSGI.Authorization.username}
	 * and call {@link VSGI.Authorization.challenge_with_password}.
	 *
	 * @since 0.3
	 *
	 * @param auth represent the credentials provided by the user-agent
	 *             which can be challenged
	 *
	 * @return 'true' if the authentication is successful, 'false' otherwise
	 *         even if the provided input is malformed
	 */
	public delegate bool AuthCallback (Authorization auth);

	/**
	 * Challenge incoming requests against the provided authentication
	 * definition.
	 *
	 * On success, the request is forwarded with the authenticated username.
	 *
	 * @since 0.3
	 */
	public HandlerCallback authenticate (Authentication                auth,
	                                     owned AuthCallback            callback,
	                                     owned ForwardCallback<string> forward = Valum.forward) {
		return (req, res, next, ctx) => {
			var authorization_header = req.headers.get_one ("Authorization");

			if (authorization_header != null) {
				Authorization authorization;
				if (auth.parse_authorization_header (authorization_header, out authorization)) {
					if (callback (authorization)) {
						return forward (req, res, next, ctx, authorization.username);
					} else {
						// authentication failed
					}
				} else {
					// malformed authentication
				}
			}

			throw new ClientError.UNAUTHORIZED (auth.to_authenticate_header ());
		};
	}
}
