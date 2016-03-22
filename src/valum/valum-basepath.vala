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

namespace Valum {

	/**
	 * Rebase and forward requests which path match the provided basepath.
	 *
	 * If the {@link Valum.Request.uri} path has the provided prefix, it is 
	 * stripped and the resulting request is forwared.
	 *
	 * Typically, a leading slash and no ending slash are used to form the
	 * prefix path (e.g. '/user').
	 *
	 * If 'next' is called while forwarding, the URI path is restored.
	 *
	 * Error which message consist of a 'Location' header are prefixed by
	 * the basepath.
	 *
	 * @since 0.3
	 *
	 * @param path
	 * @param forward callback used to forward the request
	 */
	public HandlerCallback basepath (string path, owned HandlerCallback forward) {
		return (req, res, next, context) => {
			if (req.uri.get_path ().has_prefix (path)) {
				var original_path = req.uri.get_path ();
				req.uri.set_path (req.uri.get_path ().length > path.length ? 
				                  req.uri.get_path ().substring (path.length) : "/");
				try {
					return forward (req, res, (req, res) => {
						req.uri.set_path (original_path);
						return next (req, res);
					}, context);
				} catch (Success.CREATED s) {
					s.message = s.message[0] == '/' ? (path + s.message) : s.message;
					throw s;
				} catch (Redirection r) {
					r.message = r.message[0] == '/' ? (path + r.message) : r.message;
					throw r;
				} finally {
					req.uri.set_path (original_path);
				}
			} else {
				return next (req, res);
			}
		};
	}
}
