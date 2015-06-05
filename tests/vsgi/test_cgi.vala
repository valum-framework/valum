using VSGI.CGI;

/**
 * @since 0.2
 */
public static void test_vsgi_cgi_request_translated_path () {
	var environment = new HashTable<string, string> (str_hash, str_equal);

	environment["PATH_TRANSLATED"] = "https://example.com:3003/test";

	var connection = new SimpleIOStream (new MemoryInputStream (),
	                                     new MemoryOutputStream.resizable ());

	var request = new Request (connection, environment);

	assert ("https" == request.uri.scheme);
	assert ("example.com" == request.uri.get_host ());
	assert (3003 == request.uri.get_port ());
	assert (null == request.query);
	assert (connection.input_stream == request.body);
}
