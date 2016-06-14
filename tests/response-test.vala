using VSGI.Mock;

public int main (string[] args) {
	Test.init (ref args);

	Test.add_func ("/response/expand", () => {
		var res = new Response (new Request (new Connection (), "GET", new Soup.URI ("http://localhost:3003/")));
		try {
			res.expand ("Hello world!".data);
		} catch (IOError err) {
			assert_not_reached ();
		}
		assert (Soup.Encoding.CONTENT_LENGTH == res.headers.get_encoding ());
		assert (12 == res.headers.get_content_length ());
	});

	Test.add_func ("/response/expand_utf8", () => {
		var res = new Response (new Request (new Connection (), "GET", new Soup.URI ("http://localhost:3003/")));
		try {
			res.expand_utf8 ("Hello world!");
		} catch (IOError err) {
			assert_not_reached ();
		}
		assert (Soup.Encoding.CONTENT_LENGTH == res.headers.get_encoding ());
		assert (12 == res.headers.get_content_length ());
		HashTable<string, string> @params;
		assert ("application/octet-stream" == res.headers.get_content_type (out @params));
		assert ("UTF-8" == @params["charset"]);
	});

	Test.add_func ("/response/expand_utf8/preserve_existing_charset_attribute", () => {
		var res = new Response (new Request (new Connection (), "GET", new Soup.URI ("http://localhost:3003/")));
		res.headers.set_content_type ("text/plain", Soup.header_parse_param_list ("charset=US-ASCII"));
		try {
			res.expand_utf8 ("Hello world!");
		} catch (IOError err) {
			assert_not_reached ();
		}
		assert (Soup.Encoding.CONTENT_LENGTH == res.headers.get_encoding ());
		assert (12 == res.headers.get_content_length ());
		HashTable<string, string> @params;
		assert ("text/plain" == res.headers.get_content_type (out @params));
		assert ("US-ASCII" == @params["charset"]);
	});

	return Test.run ();
}
