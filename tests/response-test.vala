using VSGI;

public int main (string[] args) {
	Test.init (ref args);

	Test.add_func ("/response/write_head", () => {
		var res = new Response (new Request.with_method ("GET", new Soup.URI ("http://localhost:3003/")));

		var wrote_status_line_emitted = false;
		var wrote_headers_emitted     = false;

		res.wrote_status_line.connect ((status, reason_phrase) => {
			assert (Soup.Status.OK == status);
			assert ("OK" == reason_phrase);
			wrote_status_line_emitted = true;
		});

		res.wrote_headers.connect ((headers) => {
			assert (res.headers != headers);
			wrote_headers_emitted = true;
		});

		try {
			size_t bytes_written;
			assert (res.write_head (out bytes_written));
		} catch (IOError err) {
			assert_not_reached ();
		}

		assert (wrote_status_line_emitted);
		assert (wrote_headers_emitted);
	});

	Test.add_func ("/response/expand", () => {
		var res = new Response (new Request.with_method ("GET", new Soup.URI ("http://localhost:3003/")));
		try {
			res.expand ("Hello world!".data);
		} catch (IOError err) {
			assert_not_reached ();
		}
		assert (Soup.Encoding.CONTENT_LENGTH == res.headers.get_encoding ());
		assert (12 == res.headers.get_content_length ());
	});

	Test.add_func ("/response/expand_bytes", () => {
		var res = new Response (new Request.with_method ("GET", new Soup.URI ("http://localhost:3003/")));
		try {
			res.expand_bytes (new Bytes.take ("Hello world!".data));
		} catch (IOError err) {
			assert_not_reached ();
		}
		assert (Soup.Encoding.CONTENT_LENGTH == res.headers.get_encoding ());
		assert (12 == res.headers.get_content_length ());
	});

	Test.add_func ("/response/expand_utf8", () => {
		var res = new Response (new Request.with_method ("GET", new Soup.URI ("http://localhost:3003/")));
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
		var res = new Response (new Request.with_method ("GET", new Soup.URI ("http://localhost:3003/")));
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

	Test.add_func ("/response/tee", () => {
		var res    = new Response (new Request.with_method ("GET", new Soup.URI ("http://localhost:3003/")));
		var buffer = new MemoryOutputStream (null, realloc, free);
		res.tee (buffer);
		try {
			res.expand_utf8 ("Hello world!");
		} catch (IOError err) {
			assert_not_reached ();
		}
		assert ("Hello world!" == (string) buffer.data);
	});

	return Test.run ();
}
