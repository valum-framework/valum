using VSGI.FastCGI;

/**
 * @since 0.2
 */
public static void test_vsgi_fastcgi_request () {
	var environment   = new HashTable<string, string?> (str_hash, str_equal);

	environment["REQUEST_METHOD"] = "GET";
	environment["SERVER_NAME"]    = "0.0.0.0";
	environment["SERVER_PORT"]    = "3003";
	environment["HTTP_HOST"]      = "example.com";

	var input_stream = new MemoryInputStream ();

	var request = new Request (environment, input_stream);

	assert (Soup.HTTPVersion.@1_0 == request.http_version);
	assert ("GET" == request.method);
	assert ("0.0.0.0" == request.uri.get_host ());
	assert (3003 == request.uri.get_port ());
	assert (null == request.query);
	assert (null == request.params);
	assert ("example.com" == request.headers.get_one ("Host"));
	assert (0 == request.cookies.length ());
	assert (input_stream == request.body);
}

/**
 * @since 0.2
 */
public static void test_vsgi_fastcgi_request_https_on () {
	var environment   = new HashTable<string, string?> (str_hash, str_equal);

	environment["HTTPS"] = "on";

	var input_stream = new MemoryInputStream ();

	var request = new Request (environment, input_stream);

	assert ("https" == request.uri.scheme);
}

/**
 * @since 0.2
 */
public static void test_vsgi_fastcgi_request_uri_with_query () {
	var environment   = new HashTable<string, string?> (str_hash, str_equal);

	environment["REQUEST_URI"] = "/home?a=b";

	var input_stream = new MemoryInputStream ();

	var request = new Request (environment, input_stream);

	assert ("/home" == request.uri.path);
}

/**
 * @since 0.2
 */
public static void test_vsgi_fastcgi_response () {
	var environment   = new HashTable<string, string?> (str_hash, str_equal);
	var input_stream  = new MemoryInputStream ();
	var output_stream = new MemoryOutputStream (null, realloc, free);

	var request = new Request (environment, input_stream);
	var response = new Response (request, output_stream);

	assert (request == response.request);
	assert (output_stream == response.body);
}
