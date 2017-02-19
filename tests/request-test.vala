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

using GLib;
using VSGI;

public int main (string[] args) {
	Test.init (ref args);

	Test.add_func ("/request/fill_query_from_uri", () => {
		var req = new Request (null, "GET", new Soup.URI ("http://localhost/?a=b"));

		assert (req.query.contains ("a"));
		assert ("b" == req.query["a"]);
	});

	Test.add_func ("/request/fill_uri_from_query", () => {
		var query = new HashTable<string, string> (str_hash, str_equal);
		query.insert ("a", "b");
		var req = new Request (null, "GET", new Soup.URI ("http://localhost/"), query);

		assert ("a=b" == req.uri.get_query ());
	});

	Test.add_func ("/request/convert/new_content_length", () => {
		var req = new Request (null, "get", new Soup.URI ("http://localhost/"));

		req.headers.set_content_length (50);

		req.convert (new ZlibCompressor (ZlibCompressorFormat.GZIP), 40);

		assert (40 == req.headers.get_content_length ());
	});

	Test.add_func ("/request/convert/eof_to_fixed_size", () => {
		var req = new Request (null, "get", new Soup.URI ("http://localhost/"));

		req.headers.set_encoding (Soup.Encoding.EOF);

		req.convert (new ZlibCompressor (ZlibCompressorFormat.GZIP), 40);

		assert (40 == req.headers.get_content_length ());
	});

	Test.add_func ("/request/convert/complete_sink", () => {
		var req = new Request (null, "get", new Soup.URI ("http://localhost/"));

		req.headers.set_content_length (50);

		req.convert (new ZlibCompressor (ZlibCompressorFormat.GZIP), 0);

		assert (Soup.Encoding.CONTENT_LENGTH == req.headers.get_encoding ());
		assert (0 == req.headers.get_content_length ());
	});

	Test.add_func ("/request/convert/chunked", () => {
		var req = new Request (null, "get", new Soup.URI ("http://localhost/"));

		req.headers.set_encoding (Soup.Encoding.CHUNKED);

		req.convert (new ZlibCompressor (ZlibCompressorFormat.GZIP), -1);

		assert (Soup.Encoding.CHUNKED == req.headers.get_encoding ());
	});

	Test.add_func ("/request/lookup_query", () => {
		assert (null == new Request (null, "GET", new Soup.URI ("http://localhost:3003/"), null).lookup_query ("a"));
		assert (null == new Request (null, "GET", new Soup.URI ("http://localhost:3003/"), Soup.Form.decode ("b")).lookup_query ("a"));
		assert (null == new Request (null, "GET", new Soup.URI ("http://localhost:3003/"), Soup.Form.decode ("a")).lookup_query ("a"));
		assert ("b" == new Request (null, "GET", new Soup.URI ("http://localhost:3003/"), Soup.Form.decode ("a=b")).lookup_query ("a"));
	});

	return Test.run ();
}

