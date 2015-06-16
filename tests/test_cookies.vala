using Soup;
using Valum;

/**
 * @since 0.1
 */
public void test_cookies_from_request_headers () {
	var headers = new MessageHeaders (MessageHeadersType.REQUEST);

	headers.append ("Cookie", "a=b");

	var cookies = Cookies.from_request_headers (headers);

	assert (1 == cookies.length ());
	assert ("a" == cookies.data.name);
	assert ("b" == cookies.data.value);
}
