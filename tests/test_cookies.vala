using Soup;
using Valum;

/**
 * @since 0.1
 */
public void test_cookies_from_request_headers () {
	var headers = new MessageHeaders (MessageHeadersType.REQUEST);

	headers.append ("Cookie", "a=b, c=d");
	headers.append ("Cookie", "e=f");

	var cookies = Cookies.from_request_headers (headers);

	assert (3 == cookies.length ());

	assert ("a" == cookies.data.name);
	assert ("b" == cookies.data.value);

	assert ("c" == cookies.next.data.name);
	assert ("d" == cookies.next.data.value);

	assert ("e" == cookies.next.next.data.name);
	assert ("f" == cookies.next.next.data.value);
}

/**
 * @since 0.3
 */
public void test_cookies_lookup () {
	var headers = new MessageHeaders (MessageHeadersType.REQUEST);

	headers.append ("Cookie", "a=b");
	headers.append ("Cookie", "a=c"); // override

	assert (null == Cookies.lookup ("b", headers));

	var cookie = Cookies.lookup ("a", headers);

	assert ("a" == cookie.name);
	assert ("c" == cookie.value);
}
