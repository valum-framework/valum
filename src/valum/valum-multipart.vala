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
	 * Forward a {@link VSGI.MultipartInputStream} if the incoming request is multipart.
	 *
	 * If the 'boundary' parameter is missing, a {@link ClientError.BAD_REQUEST}
	 * is raised.
	 *
	 * For regular requests, 'next' is called.
	 */
	[Version (since = "0.4")]
	public HandlerCallback multipart (ForwardCallback<MultipartInputStream> forward) {
		return (req, res, next, ctx) => {
			HashTable<string, string> @params;
			if (req.headers.get_content_type (out @params).has_prefix ("multipart/")) {
				if (!@params.contains ("boundary")) {
					throw new ClientError.BAD_REQUEST ("The 'boundary' parameter is missing in the 'Content-Type' header.");
				}
				return forward (req, res, next, ctx, new MultipartInputStream (req.body, @params["boundary"]));
			} else {
				return next ();
			}
		};
	}
}
