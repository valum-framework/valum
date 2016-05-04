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

using Valum;
using VSGI;

public class AdminRouter : Router {

	construct {
		use (authenticate);
		rule (Method.GET | Method.POST, "/admin/view", view);
	}

	/**
	 * Verify the user credentials and perform an authentication.
	 */
	public bool authenticate (Request req, Response res, NextCallback next) throws Error {
		string @value;
		req.lookup_signed_cookie ("session", ChecksumType.SHA256, "impossible to break".data, out @value);
		if (@value == "admin") {
			return next ();
		}

		if (req.method == Request.POST) {
			var form = Soup.Form.decode (req.flatten_utf8 ());
			if (form["password"] == "1234") {
				var session_cookie = new Soup.Cookie ("session", "admin", "", "/admin/view", Soup.COOKIE_MAX_AGE_ONE_HOUR);
				CookieUtils.sign (session_cookie, ChecksumType.SHA256, "impossible to break".data);
				res.headers.append ("Set-Cookie", session_cookie.to_set_cookie_header ());
				return next ();
			}
		}

		res.headers.set_content_type ("text/html", null);
		return res.expand_utf8 ("""
		<!DOCTYPE html>
		<html>
		  <head>
		    <title>You must authenticate!</title>
		  </head>
		  <body>
		    <form method='post'>
		      <input type='password' name='password' placeholder='1234'/>
		      <input type='submit'/>
		    </form>
		  </body>
		</html>
		""");
	}

	/**
	 * Restricted content.
	 */
	public bool view (Request req, Response res, NextCallback next, Context ctx) throws Error {
		res.headers.set_content_type ("text/plain", null);
		return res.expand_utf8 ("Hello admin!");
	}
}
