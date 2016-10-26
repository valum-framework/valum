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

/**
 * Cookie-related utilities.
 */
[CCode (gir_namespace = "VSGI", gir_version = "0.3")]
namespace VSGI.CookieUtils {

	/**
	 * Sign the provided cookie name and value in-place using HMAC.
	 *
	 * The returned value will be 'HMAC(checksum_type, name + HMAC(checksum_type, value)) + value'
	 * suitable for a cookie value which can the be verified with {@link VSGI.CookieUtils.verify}.
	 *
	 * {{{
	 * CookieUtils.sign (cookie, ChecksumType.SHA512, "super-secret".data);
	 * }}}
	 *
	 * @param cookie        cookie to sign
	 * @param checksum_type hash algorithm used to compute the HMAC
	 * @param key           secret used to sign the cookie name and value
	 */
	[Version (since = "0.3")]
	public void sign (Cookie cookie, ChecksumType checksum_type, uint8[] key) {
		var checksum = Hmac.compute_for_string (checksum_type,
		                                        key,
		                                        Hmac.compute_for_string (checksum_type, key, cookie.@value) + cookie.name);

		cookie.set_value (checksum + cookie.@value);
	}

	/**
	 * Verify a signed cookie from {@link VSGI.CookieUtils.sign}.
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
	[Version (since = "0.3")]
	public bool verify (Cookie cookie, ChecksumType checksum_type, uint8[] key, out string? @value) {
		var checksum_length = Hmac.compute_for_string (checksum_type, key, "").length;
		@value              = null;

		if (cookie.@value.length < checksum_length)
			return false;

		var checksum = Hmac.compute_for_string (checksum_type,
		                                        key,
		                                        Hmac.compute_for_string (checksum_type, key, cookie.@value.substring (checksum_length)) + cookie.name);

		assert (checksum_length == checksum.length);

		if (str_const_equal (checksum, cookie.@value.substring (0, checksum_length))) {
			@value = cookie.@value.substring (checksum_length);
			return true;
		} else {
			return false;
		}
	}
}
