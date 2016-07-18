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
	 * Provide a set of basic behaviours such as status and error handling.
	 *
	 * Raised status code are handled according to the expectations of the HTTP
	 * specification.
	 *
	 * Other errors are treated as '500 Internal Server Error' with a
	 * pre-defined payload.
	 *
	 * @since 0.3
	 */
	public HandlerCallback basic () {
		return (req, res, next) => {
			try {
				return next ();
			} catch (Error err) {
				/*
				 * If an error happen after 'write_head' is called, it's already
				 * too late to perform any kind of status handling.
				 */
				if (res.head_written) {
					critical ("%s", err.message);
					return true;
				}

				/*
				 * Turn non-status into '500 Internal Server Error'
				 */
				res.status = is_status (err) ? err.code : 500;

				/*
				 * The error message is used as a header if the HTTP/1.1
				 * specification indicate that it MUST be provided.
				 *
				 * The content encoding is set to NONE if the HTTP/1.1
				 * specification indicates that an entity MUST NOT be
				 * provided.
				 *
				 * For practical purposes, the error message is used for the
				 * 'Location' of redirection codes.
				 */
				switch (res.status) {
					case global::Soup.Status.SWITCHING_PROTOCOLS:
						res.headers.replace ("Upgrade", err.message);
						res.headers.set_encoding (Soup.Encoding.NONE);
						break;

					case global::Soup.Status.CREATED:
						res.headers.replace ("Location", err.message);
						break;

					case global::Soup.Status.ACCEPTED:
						res.headers.replace ("Content-Location", err.message);
						break;

					// no content
					case global::Soup.Status.NO_CONTENT:
					case global::Soup.Status.RESET_CONTENT:
						res.headers.set_encoding (Soup.Encoding.NONE);
						break;

					case global::Soup.Status.PARTIAL_CONTENT:
						res.headers.replace ("Range", err.message);
						break;

					case global::Soup.Status.MOVED_PERMANENTLY:
					case global::Soup.Status.FOUND:
					case global::Soup.Status.SEE_OTHER:
						res.headers.replace ("Location", err.message);
						break;

					case global::Soup.Status.NOT_MODIFIED:
						res.headers.set_encoding (Soup.Encoding.NONE);
						break;

					case global::Soup.Status.USE_PROXY:
					case global::Soup.Status.TEMPORARY_REDIRECT:
						res.headers.replace ("Location", err.message);
						break;

					case global::Soup.Status.UNAUTHORIZED:
						res.headers.replace ("WWW-Authenticate", err.message);
						break;

					case global::Soup.Status.METHOD_NOT_ALLOWED:
						res.headers.append ("Allow", err.message);
						break;

					case 426: // Upgrade Required
						res.headers.replace ("Upgrade", err.message);
						break;

					// basic handling
					default:
						var @params = new HashTable<string, string> ((HashFunc<string>) Soup.str_case_hash,
						                                             (EqualFunc<string>) Soup.str_case_equal);
						@params["charset"] = "utf-8";
						res.headers.set_content_type ("text/plain", @params);
						try {
							if (is_status (err)) {
								return res.expand_utf8 (err.message);
							} else {
								critical (err.message);
								return res.expand_utf8 ("The server encountered an unexpected condition which prevented it from fulfilling the request.");
							}
						} catch (IOError io_err) {
							critical (io_err.message);
						}
						break;
				}

				try {
					return res.end ();
				} catch (IOError io_err) {
					critical (io_err.message);
					return true;
				}
			}
		};
	}
}
