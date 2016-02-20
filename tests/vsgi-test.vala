

using GLib;
using VSGI.Mock;

public int main (string[] args) {
	Test.init (ref args);

	Test.add_func ("/vsgi/converted_request", () => {
		var request           = new Request (new Connection (), "GET", new Soup.URI ("http://127.0.0.1:3003/"));
		var converted_request = new VSGI.ConvertedRequest (request, new ZlibDecompressor (ZlibCompressorFormat.GZIP));

		// ensure that all properties are forward properly
		assert (request.method == converted_request.method);
		assert (request.uri == converted_request.uri);
		assert (request.query == converted_request.query);
		assert (request.headers == converted_request.headers);

		assert (converted_request.body is ConverterInputStream);
	});

	Test.add_func ("/vsgi/converted_response", () => {
		var request            = new Request (new Connection (), "GET", new Soup.URI ("http://127.0.0.1:3003/"));
		var response           = new Response (request);
		var converted_response = new VSGI.ConvertedResponse (response, new ZlibCompressor (ZlibCompressorFormat.GZIP));

		// ensure that all properties are forward properly
		assert (response.request == converted_response.request);
		assert (response.status == converted_response.status);
		assert (response.reason_phrase == converted_response.reason_phrase);
		assert (response.headers == converted_response.headers);

		assert (converted_response.body is ConverterOutputStream);

		assert (response.head_written);
		assert (converted_response.head_written);
	});

	return Test.run ();
}
