using VSGI.CGI;

/**
 * @since 0.2
 */
public static void test_vsgi_cgi_request () {
	var environment   = new HashTable<string, string> (str_hash, str_equal);

	environment["PATH_INFO"]      = "/";
	environment["REQUEST_METHOD"] = "GET";
	environment["SERVER_NAME"]    = "0.0.0.0";
	environment["SERVER_PORT"]    = "3003";
	environment["HTTP_HOST"]      = "example.com";

	var connection = new VSGI.Test.Connection ();
	var request    = new Request (connection, environment);

	assert (Soup.HTTPVersion.@1_0 == request.http_version);
	assert ("GET" == request.method);
	assert ("0.0.0.0" == request.uri.get_host ());
	assert (3003 == request.uri.get_port ());
	assert (null == request.query);
	assert (null == request.params);
	assert ("example.com" == request.headers.get_one ("Host"));
	assert (connection.input_stream == request.body);
}

/**
 * @since 0.2
 */
public static void test_vsgi_cgi_request_missing_path_info () {
	var environment = new HashTable<string, string> (str_hash, str_equal);

	environment["PATH_INFO"] = "/test";

	var connection = new VSGI.Test.Connection ();

	var request = new Request (connection, environment);

	assert ("/test" == request.uri.get_path ());
}

