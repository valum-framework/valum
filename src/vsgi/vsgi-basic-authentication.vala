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
 * Parse and generate basic authentication headers according to RFC 7617.
 *
 * [[https://tools.ietf.org/html/rfc7617]]
 *
 * @since 0.3
 */
public class VSGI.BasicAuthentication : Authentication {

	/**
	 * @since 0.3
	 */
	public BasicAuthentication (string realm, string? charset = null) {
		Object (realm: realm, charset: charset);
	}

	public override bool parse_authorization_header (string header, out Authorization? authorization) {
		authorization = null;

		if (header.length < 6) {
			return false;
		}

		if (!Soup.str_case_equal (header.slice (0, 5), "Basic")) {
			return false;
		}

		var authorization_data = (string) Base64.decode (header.substring (6));

		if (charset != null && !Soup.str_case_equal (charset, "UTF-8")) {
			try {
				authorization_data = convert (authorization_data, authorization_data.length, "UTF-8", charset);
			} catch (ConvertError err) {
				critical (err.message);
				return false;
			}
		}

		var sep_index = authorization_data.index_of_char (':');

		if (sep_index == -1) {
			return false;
		}

		authorization = new BasicAuthorization (authorization_data.slice (0, sep_index),
		                                        authorization_data.substring (sep_index + 1));

		return true;
	}

	public override string to_authenticate_header () {
		var auth_header = new StringBuilder ("Basic");
		Soup.header_g_string_append_param_quoted (auth_header, " realm", realm);
		if (charset != null) {
			Soup.header_g_string_append_param_quoted (auth_header, ", charset", charset);
		}
		return auth_header.str;
	}
}

