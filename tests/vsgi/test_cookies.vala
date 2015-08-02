using VSGI.Test;

/**
 * @since 0.1
 */
public void test_vsgi_cookies_from_request () {
	var req = new Request ("GET", new Soup.URI ("http://localhost/"));

	req.headers.append ("Cookie", "a=b, c=d");
	req.headers.append ("Cookie", "e=f");

	var cookies = VSGI.Cookies.from_request (req);

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
	var req = new Request ("GET", new Soup.URI ("http://localhost/"));
	var res = new Response (req, 200);

	res.headers.append ("Set-Cookie", "a=b, c=d");
	res.headers.append ("Set-Cookie", "e=f");

	var cookies = VSGI.Cookies.from_response (res);

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
	var req = new Request ("GET", new Soup.URI ("http://localhost/"));

	req.headers.append ("Cookie", "a=b");
	req.headers.append ("Cookie", "a=c"); // override

	var cookies = VSGI.Cookies.from_request (req);

	assert (null == VSGI.Cookies.lookup (cookies, "b"));

	var cookie = VSGI.Cookies.lookup (cookies, "a");

	assert ("a" == cookie.name);
	assert ("c" == cookie.value);
}
