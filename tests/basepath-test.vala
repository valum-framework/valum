using Valum;
using VSGI.Mock;

public int main (string[] args) {
	Test.init (ref args);

	Test.add_func ("/basepath", () => {
		var req = new Request.with_uri (new Soup.URI ("http://localhost/base/"));
		var res = new Response (req);
		var ctx = new Context ();

		try {
			basepath ("/base", (req) => {
				assert ("/" == req.uri.get_path ());
				return true;
			}) (req, res, () => {
				assert_not_reached ();
			}, ctx);
		} catch (Error err) {
			assert_not_reached ();
		}
	});

	Test.add_func ("/basepath/empty_path", () => {
		var req = new Request.with_uri (new Soup.URI ("http://localhost/base"));
		var res = new Response (req);
		var ctx = new Context ();

		try {
			basepath ("/base", (req) => {
				assert ("/" == req.uri.get_path ());
				return true;
			}) (req, res, () => {
				assert_not_reached ();
			}, ctx);
		} catch (Error err) {
			assert_not_reached ();
		}
	});

	return Test.run ();
}
