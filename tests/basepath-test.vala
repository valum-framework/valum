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

	Test.add_func ("/basepath/restore_path_on_next", () => {
		var req = new Request.with_uri (new Soup.URI ("http://localhost/base"));
		var res = new Response (req);
		var ctx = new Context ();

		try {
			basepath ("/base", (req, res, next) => {
				assert ("/" == req.uri.get_path ());
				return next ();
			}) (req, res, () => {
				assert ("/base" == req.uri.get_path ());
				return true;
			}, ctx);
		} catch (Error err) {
			assert_not_reached ();
		}
	});

	Test.add_func ("/basepath/restore_path_on_error", () => {
		var req = new Request.with_uri (new Soup.URI ("http://localhost/base"));
		var res = new Response (req);
		var ctx = new Context ();

		try {
			basepath ("/base", (req, res, next) => {
				assert ("/" == req.uri.get_path ());
				throw new ClientError.NOT_FOUND ("");
			}) (req, res, () => {
				assert_not_reached ();
			}, ctx);
		} catch (ClientError.NOT_FOUND r) {
			assert ("/base" == req.uri.get_path ());
		} catch (Error err) {
			assert_not_reached ();
		}
	});

	Test.add_func ("/basepath/rewrite_location_header", () => {
		var req = new Request.with_uri (new Soup.URI ("http://localhost/base"));
		var res = new Response (req);
		var ctx = new Context ();

		try {
			basepath ("/base", (req, res, next) => {
				assert ("/" == req.uri.get_path ());
				res.headers.replace ("Location", "/5");
				return next ();
			}) (req, res, () => {
				assert ("/base/5" == res.headers.get_one ("Location"));
				return true;
			}, ctx);
		} catch (Error err) {
			assert_not_reached ();
		}
	});

	Test.add_func ("/basepath/rewrite_location_header_on_error", () => {
		var req = new Request.with_uri (new Soup.URI ("http://localhost/base"));
		var res = new Response (req);
		var ctx = new Context ();

		try {
			basepath ("/base", (req, res, next) => {
				assert ("/" == req.uri.get_path ());
				res.headers.replace ("Location", "/5");
				throw new ClientError.NOT_FOUND ("");
			}) (req, res, () => {
				assert_not_reached ();
			}, ctx);

		} catch (ClientError err) {
			assert ("/base/5" == res.headers.get_one ("Location"));
		} catch (Error err) {
			assert_not_reached ();
		}
	});

	Test.add_func ("/basepath/success_created/prefix_message", () => {
		var req = new Request.with_uri (new Soup.URI ("http://localhost/base"));
		var res = new Response (req);
		var ctx = new Context ();

		try {
			basepath ("/base", (req, res, next) => {
				assert ("/" == req.uri.get_path ());
				throw new Success.CREATED ("/5");
			}) (req, res, () => {
				assert_not_reached ();
			}, ctx);
		} catch (Success.CREATED s) {
			assert ("/base/5" == s.message);
			assert ("/base" == req.uri.get_path ());
		} catch (Error err) {
			assert_not_reached ();
		}
	});

	Test.add_func ("/basepath/success_created/omit_non_relative_message", () => {
		var req = new Request.with_uri (new Soup.URI ("http://localhost/base"));
		var res = new Response (req);
		var ctx = new Context ();

		try {
			basepath ("/base", (req, res, next) => {
				assert ("/" == req.uri.get_path ());
				throw new Success.CREATED ("http://localhost/5");
			}) (req, res, () => {
				assert_not_reached ();
			}, ctx);
		} catch (Success.CREATED s) {
			assert ("http://localhost/5" == s.message);
			assert ("/base" == req.uri.get_path ());
		} catch (Error err) {
			assert_not_reached ();
		}
	});

	return Test.run ();
}
