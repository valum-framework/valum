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

using VSGI;

/**
 * @since 0.1
 */
public void test_vsgi_cookies_from_request () {
	var req = new Request.with_uri (new Soup.URI ("http://localhost/"));

	req.headers.append ("Cookie", "a=b, c=d");
	req.headers.append ("Cookie", "e=f");

	var cookies = req.cookies;

	assert (3 == cookies.length ());

	assert ("a" == cookies.data.name);
	assert ("b" == cookies.data.value);

	assert ("c" == cookies.next.data.name);
	assert ("d" == cookies.next.data.value);

	assert ("e" == cookies.next.next.data.name);
	assert ("f" == cookies.next.next.data.value);
}

/**
 * @since 0.1
 */
public void test_vsgi_cookies_from_response () {
	var req = new Request.with_uri (new Soup.URI ("http://localhost/"));
	var res = new Response (req);

	res.headers.append ("Set-Cookie", "a=b, c=d");
	res.headers.append ("Set-Cookie", "e=f");

	var cookies = res.cookies;

	assert (3 == cookies.length ());

	assert ("a" == cookies.data.name);
	assert ("b" == cookies.data.value);

	assert ("c" == cookies.next.data.name);
	assert ("d" == cookies.next.data.value);

	assert ("e" == cookies.next.next.data.name);
	assert ("f" == cookies.next.next.data.value);
}

/**
 * @since 0.2
 */
public void test_vsgi_cookies_lookup () {
	var req = new Request.with_uri (new Soup.URI ("http://localhost/"));

	req.headers.append ("Cookie", "a=b");
	req.headers.append ("Cookie", "a=c"); // override

	assert (null == req.lookup_cookie ("b"));

	var cookie = req.lookup_cookie ("a");

	assert ("a" == cookie.name);
	assert ("c" == cookie.value);
}

/**
 * @since 0.2
 */
public void test_vsgi_cookies_sign () {
	var cookie = new Soup.Cookie ("name", "value", "0.0.0.0", "/", 3600);

	VSGI.CookieUtils.sign (cookie, ChecksumType.SHA256, "secret".data);

	assert ("5d5305a844da2aa20b85bccd0067abf794ff439a9749c17527d8d9f7c2a6cf87value" == cookie.@value);
}

/**
 * @since 0.2
 */
public void test_vsgi_cookies_sign_empty_cookie () {
	var cookie    = new Soup.Cookie ("name", "", "0.0.0.0", "/", 3600);
	VSGI.CookieUtils.sign (cookie, ChecksumType.SHA256, "secret".data);

	assert ("d6c8fc143254f1f9135210d09f6058414bbec029cc267f1e9c5e70da347eb3e9" == cookie.@value);
}

/**
 * @since 0.2
 */
public void test_vsgi_cookies_sign_and_verify () {
	var cookie = new Soup.Cookie ("name", "value", "0.0.0.0", "/", 3600);

	VSGI.CookieUtils.sign (cookie, ChecksumType.SHA256, "secret".data);

	string @value;
	assert (VSGI.CookieUtils.verify (cookie, ChecksumType.SHA256, "secret".data, out @value));
	assert ("value" == @value);
}

/**
 * @since 0.2
 */
public void test_vsgi_cookies_verify () {
	var cookie = new Soup.Cookie ("name",
								  "5d5305a844da2aa20b85bccd0067abf794ff439a9749c17527d8d9f7c2a6cf87value",
	                              "0.0.0.0",
	                              "/",
	                              3600);

	string @value;
	assert (VSGI.CookieUtils.verify (cookie, ChecksumType.SHA256, "secret".data, out @value));
	assert ("value" == @value);
}

/**
 * @since 0.2
 */
public void test_vsgi_cookies_verify_bad_signature () {
	var cookie = new Soup.Cookie ("name",
								  "5d5305a844da2aa20b85bccd0067abf794ff439a9749c17527d8d9f7c2a6cf88value",
	                              "0.0.0.0",
	                              "/",
	                              3600);

	string @value;
	assert (!VSGI.CookieUtils.verify (cookie, ChecksumType.SHA256, "secret".data, out @value));
	assert (null == @value);
}

/**
 * @since 0.2
 */
public void test_vsgi_cookies_verify_too_small_value () {
	var cookie = new Soup.Cookie ("name", "value", "0.0.0.0", "/", 3600);

	assert ("value".length < Hmac.compute_for_string (ChecksumType.SHA256, "secret".data, "value").length);

	string @value;
	assert (!VSGI.CookieUtils.verify (cookie, ChecksumType.SHA256, "secret".data, out @value));
	assert (null == @value);
}
