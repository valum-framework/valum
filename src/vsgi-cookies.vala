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

using Soup;

namespace VSGI.Cookies {

	/**
	 * Extract cookies from the 'Cookie' headers.
	 *
	 * @since 0.2
	 *
	 * @param request request from which cookies will be extracted
	 */
	public SList<Cookie> from_request (Request request) {
		var cookies     = new SList<Cookie> ();
		var cookie_list = request.headers.get_list ("Cookie");

		if (cookie_list == null)
			return cookies;

		foreach (var cookie in cookie_list.split (","))
			if (cookie != null)
				cookies.prepend (Cookie.parse (cookie, null));

		cookies.reverse ();

		return cookies;
	}

	/**
	 * Extract cookies from the 'Set-Cookie' headers.
	 *
	 * @since 0.2
	 *
	 * @param response response from which cookies will be extracted
	 */
	public SList<Cookie> from_response (Response response) {
		var cookies     = new SList<Cookie> ();
		var cookie_list = response.headers.get_list ("Set-Cookie");

		if (cookie_list == null)
			return cookies;

		foreach (var cookie in cookie_list.split (","))
			if (cookie != null)
				cookies.prepend (Cookie.parse (cookie, response.request.uri));

		cookies.reverse ();

		return cookies;
	}

	/**
	 * Lookup a cookie by its name.
	 *
	 * The last occurence is returned using a case-sensitive match.
	 *
	 * @since 0.2
	 *
	 * @param cookies cookies typically extracted from {@link VSGI.Cookies.from_request}
	 * @param name    name of the cookie to lookup
	 * @return the cookie if found, otherwise null
	 */
	public Cookie? lookup (SList<Cookie> cookies, string name) {
		Cookie? found = null;

		foreach (var cookie in cookies)
			if (cookie.name == name)
				found = cookie;

		return found;
	}

	/**
	 * Sign the provided cookie name and value using HMAC.
	 *
	 * The returned value will be 'HMAC(checksum_type, name + HMAC(checksum_type, value)) + value'
	 * suitable for a cookie value which can the be verified with {@link VSGI.Cookies.verify}.
	 *
	 * {{{
	 * cookie.@value = Cookies.sign (cookie, ChecksumType.SHA512, "super-secret".data);
	 * }}}
	 *
	 * @param cookie        cookie to sign
	 * @param checksum_type hash algorithm used to compute the HMAC
	 * @param key           secret used to sign the cookie name and value
	 * @return              the signed value for the provided cookie, which can
	 *                      be reassigned in the cookie
	 */
	public string sign (Cookie cookie, ChecksumType checksum_type, uint8[] key) {
		var checksum = Hmac.compute_for_string (checksum_type,
		                                        key,
		                                        Hmac.compute_for_string (checksum_type, key, cookie.@value) + cookie.name);

		return checksum + cookie.@value;
	}

	/**
	 * Verify a signed cookie from {@link VSGI.Cookies.sign}.
	 *
	 * The signature is verified in constant time, more specifically a number
	 * of comparisons equal to length of the checksum.
	 *
	 * @param cookie        cookie which signature will be verified
	 * @param checksum_type hash algorithm used to compute the HMAC
	 * @param key           secret used to sign the cookie's value
	 * @param value         cookie's value extracted from its signature if the
	 *                      verification succeeds, null otherwise
	 * @return              true if the cookie is signed by the secret
	 */
	public bool verify (Cookie cookie, ChecksumType checksum_type, uint8[] key, out string? @value = null) {
		var checksum_length = Hmac.compute_for_string (checksum_type, key, "").length;

		if (cookie.@value.length < checksum_length)
			return false;

		var checksum = Hmac.compute_for_string (checksum_type,
		                                        key,
												Hmac.compute_for_string (checksum_type, key, cookie.@value.substring (checksum_length)) + cookie.name);

		assert (checksum_length == checksum.length);

		var match = 0;

		// constant-time equal to avoid time-based attacks
		for (int i = 0; i < checksum.length; i++)
			match |= checksum[i] ^ cookie.@value.substring (0, checksum_length)[i];

		if (match == 0)
			@value = cookie.@value.substring (checksum_length);

		return match == 0;
	}
}
