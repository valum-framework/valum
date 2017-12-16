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

	[Version (since = "0.3")]
	public enum CacheControlDirective {
		PUBLIC,
		PRIVATE,
		NO_CACHE,
		NO_STORE,
		NO_TRANSFORM,
		MUST_REVALIDATE,
		PROXY_REVALIDATE,
		MAX_AGE,
		S_MAXAGE
	}

	/**
	 * Produce a 'Cache-Control' response header.
	 *
	 * @param directive directive for the 'Cache-Control' header
	 * @param max_age   argument for 'max-age' or 's-maxage' directives if
	 *                  specified in the type, otherwise it's used for 'max-age'
	 *                  if greater than zero
	 */
	[Version (since = "0.3")]
	public HandlerCallback cache_control (CacheControlDirective directive, TimeSpan max_age = 0) {
		return (req, res, next) => {
			var cache_control_header = new StringBuilder ();

			switch (directive) {
				case CacheControlDirective.PUBLIC:
				case CacheControlDirective.PRIVATE:
				case CacheControlDirective.NO_CACHE:
				case CacheControlDirective.NO_STORE:
				case CacheControlDirective.NO_TRANSFORM:
				case CacheControlDirective.MUST_REVALIDATE:
				case CacheControlDirective.PROXY_REVALIDATE:
					cache_control_header.append (directive.to_string ().replace ("_", "-").down ()[30:directive.to_string ().length]);
					if (max_age > 0) {
						cache_control_header.append_printf (", max-age=%" + int64.FORMAT, max_age / TimeSpan.SECOND);
					}
					break;
				case CacheControlDirective.MAX_AGE:
					cache_control_header.append_printf ("max-age=%" + int64.FORMAT, max_age / TimeSpan.SECOND);
					break;
				case CacheControlDirective.S_MAXAGE:
					cache_control_header.append_printf ("s-maxage=%" + int64.FORMAT, max_age / TimeSpan.SECOND);
					break;
			}

			res.headers.append ("Cache-Control", cache_control_header.str);

			return next ();
		};
	}
}
