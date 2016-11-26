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

/**
 * @since 0.3
 */
public void test_decode_gzip () {
	var req = new Request.with_method ("POST", new Soup.URI ("http://127.0.0.1/"));
	var res = new Response (req);

	req.headers.append ("Content-Encoding", "gzip");

	assert ("gzip" == req.headers.get_list ("Content-Encoding"));

	try {
		decode () (req, res, () => {
			assert (null == req.headers.get_list ("Content-Encoding"));
			return true;
		}, new Context ());
	} catch (Error err) {
		assert_not_reached ();
	}
}

/**
 * @since 0.3
 */
public void test_decode_xgzip () {
	var req = new Request.with_method ("POST", new Soup.URI ("http://127.0.0.1/"));
	var res = new Response (req);

	req.headers.append ("Content-Encoding", "x-gzip");

	assert ("x-gzip" == req.headers.get_list ("Content-Encoding"));

	try {
		decode () (req, res, () => {
			assert (null == req.headers.get_list ("Content-Encoding"));
			return true;
		}, new Context ());
	} catch (Error err) {
		assert_not_reached ();
	}
}

/**
 * @since 0.3
 */
public void test_decode_deflate () {
	var req = new Request.with_method ("POST", new Soup.URI ("http://127.0.0.1/"));
	var res = new Response (req);

	req.headers.append ("Content-Encoding", "deflate");

	assert ("deflate" == req.headers.get_list ("Content-Encoding"));

	try {
		decode () (req, res, () => {
			assert (null == req.headers.get_list ("Content-Encoding"));
			return true;
		}, new Context ());
	} catch (Error err) {
		assert_not_reached ();
	}
}

/**
 * @since 0.3
 */
public void test_decode_identity () {
	var req = new Request.with_method ("POST", new Soup.URI ("http://127.0.0.1/"));
	var res = new Response (req);

	req.headers.append ("Content-Encoding", "identity");

	assert ("identity" == req.headers.get_list ("Content-Encoding"));

	try {
		decode () (req, res, () => {
			assert (null == req.headers.get_list ("Content-Encoding"));
			return true;
		}, new Context ());
	} catch (Error err) {
		assert_not_reached ();
	}
}

/**
 * @since 0.3
 */
public void test_decode_unknown_encoding () {
	var req = new Request.with_method ("POST", new Soup.URI ("http://127.0.0.1/"));
	var res = new Response (req);

	req.headers.append ("Content-Encoding", "br, gzip");

	try {
		decode () (req, res, () => {
			assert_not_reached ();
		}, new Context ());
		assert_not_reached ();
	} catch (ClientError.UNSUPPORTED_MEDIA_TYPE err) {
		assert ("br" == req.headers.get_list ("Content-Encoding"));
	} catch (Error err) {
		assert_not_reached ();
	}
}

/**
 * @since 0.3
 */
public void test_decode_forward_remaining_encodings () {
	var req = new Request.with_method ("POST", new Soup.URI ("http://127.0.0.1/"));
	var res = new Response (req);

	req.headers.append ("Content-Encoding", "gzip, br, deflate"); // brotli is not handled

	try {
		decode (DecodeFlags.FORWARD_REMAINING_ENCODINGS) (req, res, () => {
			assert ("gzip, br" == req.headers.get_list ("Content-Encoding"));
			return true;
		}, new Context ());
	} catch (Error err) {
		assert_not_reached ();
	}
}

