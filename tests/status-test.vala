using GLib;
using VSGI.Mock;
using Valum;

public int main (string[] args) {
	Test.init (ref args);

	Test.add_func ("/status/propagates_error_message", () => {
		var router = new Router ();

		router.use (status (404, (req, res, next, context, err) => {
			res.status = 418;
			assert ("The request URI / was not found." == err.message);
			return true;
		}));

		router.use (() => {
			throw new ClientError.NOT_FOUND ("The request URI / was not found.");
		});

		var request = new Request.with_uri (new Soup.URI ("http://localhost/"));
		var response = new Response (request);

		router.handle (request, response);

		assert (418 == response.status);
	});

	Test.add_func ("/status/forward_to_default_handler", () => {
		var router = new Router ();
		var req = new Request.with_uri (new Soup.URI ("http://localhost/"));
		var res = new Response (req);

		router.use (basic ());

		router.use (status (404, (req, res, next, ctx, err) => {
			assert ("I'm a teapot!" == err.message);
			try {
				return next ();
			} catch (ClientError.NOT_FOUND err) {
				assert ("I'm a teapot!" == err.message);
				throw err;
			}
		}));

		router.get ("/", () => {
			throw new ClientError.NOT_FOUND ("I'm a teapot!");
		});

		router.handle (req, res);

		assert (404 == res.status);
	});

	Test.add_func ("/status/forward_upstream", () => {
		var router = new Router ();
		var req = new Request.with_uri (new Soup.URI ("http://localhost/"));
		var res = new Response (req);

		router.use (status (404, (req, res, next, ctx, err) => {
			res.status = 418;
			assert ("I'm a teapot!" == err.message);
			return true;
		}));

		router.use (status (404, (req, res, next, ctx, err) => {
			assert ("I'm a teapot!" == err.message);
			return next ();
		}));

		router.get ("/", () => { throw new ClientError.NOT_FOUND ("I'm a teapot!"); });

		router.handle (req, res);

		assert (418 == res.status);
	});

	/**
	 * @since 0.2.2
	 */
	Test.add_func ("/status/handle_error", () => {
		var router = new Router ();

		router.use ((req, res, next, ctx) => {
			try {
				next ();
				assert_not_reached ();
			} catch (IOError err) {
				res.status = 418;
				assert ("Just failed!" == err.message);
				return true;
			}
		});

		router.get ("/", (req, res) => {
			throw new IOError.FAILED ("Just failed!");
		});

		var req = new Request.with_uri (new Soup.URI ("http://localhost/"));
		var res = new Response (req);

		assert (router.handle (req, res));

		assert (418 == res.status);
	});

	Test.add_func ("/status/feedback_error", () => {
		var router = new Router ();

		router.use (status (302, (req, res, next, ctx) => {
			res.status = 418;
			return true;
		}));

		router.use (status (500, (req, res, next, ctx) => {
			throw new Redirection.MOVED_TEMPORARILY ("b");
		}));

		router.get ("/", (req, res) => {
			throw new ServerError.INTERNAL_SERVER_ERROR ("a");
		});

		var req = new Request.with_uri (new Soup.URI ("http://localhost/"));
		var res = new Response (req);

		assert (router.handle (req, res));

		assert (418 == res.status);
	});

	return Test.run ();
}
