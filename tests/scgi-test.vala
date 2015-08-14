using VSGI.SCGI;

/**
 * @since 0.2
 */
public void test_vsgi_scgi_request_with_request_uri () {
	var environment   = new HashTable<string, string> (str_hash, str_equal);

	environment["REQUEST_METHOD"] = "GET";
	environment["SERVER_NAME"]    = "0.0.0.0";
	environment["SERVER_PORT"]    = "3003";
	environment["REQUEST_URI"]    = "/home?a=b";

	var connection = new VSGI.Test.Connection ();
	var request    = new Request (connection, environment);

	assert ("/home" == request.uri.path);
}
