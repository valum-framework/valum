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

using Valum;
using VSGI;

public int main (string[] args) {
	Test.init (ref args);

	/**
	 * @since 0.1
	 */
	Test.add_func ("/router", () => {
		var router = new Router ();
		router.get ("/<int:i>", (req, res) => { return true; });
		router.get ("/<string:i>", (req, res) => { return true; });
		router.get ("/<path:i>", (req, res) => { return true; });
	});

	/**
	 * @since 0.2
	 */
	Test.add_func ("/router/handle", () => {
		var router = new Router ();

		router.get ("/", (req, res) => {
			res.status = 418;
			return true;
		});

		var request  = new Request.with_uri (new Soup.URI ("http://localhost/"));
		var response = new Response (request);

		message (request.gateway_interface);

		try {
			router.handle (request, response);
		} catch (Error err) {
			assert_not_reached ();
		}

		HashTable<string, string>? @params;
		assert (418 == response.status);
		assert (null == response.headers.get_content_type (out @params));
	});

	Test.add_func ("/router/once", () => {
		var router = new Router ();

		router.once (() => {
			return true;
		});

		router.get ("/", () => {
			return false;
		});

		var req = new Request.with_uri (new Soup.URI ("http://localhost/"));
		var res = new Response (req);

		try {
			assert (router.handle (req, res));
			assert (!router.handle (req, res));
		} catch (Error err) {
			assert_not_reached ();
		}
	});

	/**
	 * @since 0.3
	 */
	Test.add_func ("/router/asterisk", () => {
		var router = new Router ();

		router.asterisk (Method.OPTIONS, (req, res) => {
			res.status = 418;
			return true;
		});

		var uri = new Soup.URI ("http://127.0.0.1:3003/*");

		uri.set_path ("*");

		var request  = new Request.with_method ("OPTIONS", uri);
		var response = new Response (request);

		try {
			router.handle (request, response);
		} catch (Error err) {
			assert_not_reached ();
		}

		assert (418 == response.status);
	});

	/**
	 * @since 0.1
	 */
	Test.add_func ("/router/get", () => {
		var router = new Router ();

		router.get ("/", (req, res) => {
			res.status = 418;
			return true;
		});

		var request  = new Request.with_uri (new Soup.URI ("http://localhost/"));
		var response = new Response (request);

		try {
			router.handle (request, response);
		} catch (Error err) {
			assert_not_reached ();
		}

		assert (418 == response.status);
	});

	/**
	 * @since 0.3
	 */
	Test.add_func ("/router/get/default_head", () => {
		var router = new Router ();

		router.get ("/", (req, res) => {
			res.status = 418;
			return true;
		});

		var request  = new Request.with_method ("HEAD", new Soup.URI ("http://localhost/"));
		var response = new Response (request);

		try {
			router.handle (request, response);
		} catch (Error err) {
			assert_not_reached ();
		}

		assert (418 == response.status);
	});

	/**
	 * @since 0.3
	 */
	Test.add_func ("/router/only_get", () => {
		var router = new Router ();

		router.rule (Method.ONLY_GET, "/", (req, res) => {
			res.status = 418;
			return true;
		});

		var request  = new Request.with_method ("GET", new Soup.URI ("http://localhost/"));
		var response = new Response (request);

		try {
			router.handle (request, response);
		} catch (Error err) {
			assert_not_reached ();
		}

		assert (418 == response.status);
	});

	/**
	 * @since 0.1
	 */
	Test.add_func ("/router/post", () => {
		var router = new Router ();

		router.post ("/", (req, res) => {
			res.status = 418;
			return true;
		});

		var request  = new Request.with_method ("POST", new Soup.URI ("http://localhost/"));
		var response = new Response (request);

		try {
			router.handle (request, response);
		} catch (Error err) {
			assert_not_reached ();
		}

		assert (418 == response.status);
	});

	/**
	 * @since 0.1
	 */
	Test.add_func ("/router/put", () => {
		var router = new Router ();

		router.put ("/", (req, res) => {
			res.status = 418;
			return true;
		});

		var request  = new Request.with_method (VSGI.Request.PUT, new Soup.URI ("http://localhost/"));
		var response = new Response (request);

		try {
			router.handle (request, response);
		} catch (Error err) {
			assert_not_reached ();
		}

		assert (418 == response.status);
	});

	/**
	 * @since 0.1
	 */
	Test.add_func ("/router/delete", () => {
		var router = new Router ();

		router.delete ("/", (req, res) => {
			res.status = 418;
			return true;
		});

		var request  = new Request.with_method (VSGI.Request.DELETE, new Soup.URI ("http://localhost/"));
		var response = new Response (request);

		try {
			router.handle (request, response);
		} catch (Error err) {
			assert_not_reached ();
		}

		assert (418 == response.status);
	});

	/**
	 * @since 0.1
	 */
	Test.add_func ("/router/head", () => {
		var router = new Router ();

		router.head ("/", (req, res) => {
			res.status = 418;
			return true;
		});

		var request  = new Request.with_method (VSGI.Request.HEAD, new Soup.URI ("http://localhost/"));
		var response = new Response (request);

		try {
			router.handle (request, response);
		} catch (Error err) {
			assert_not_reached ();
		}

		assert (418 == response.status);
	});

	/**
	 * @since 0.1
	 */
	Test.add_func ("/router/options", () => {
		var router = new Router ();

		router.options ("/", (req, res) => {
			res.status = 418;
			return true;
		});

		var request  = new Request.with_method (VSGI.Request.OPTIONS, new Soup.URI ("http://localhost/"));
		var response = new Response (request);

		try {
			router.handle (request, response);
		} catch (Error err) {
			assert_not_reached ();
		}

		assert (418 == response.status);
	});

	/**
	 * @since 0.1
	 */
	Test.add_func ("/router/trace", () => {
		var router = new Router ();

		router.trace ("/", (req, res) => {
			res.status = 418;
			return true;
		});

		var request  = new Request.with_method (VSGI.Request.TRACE, new Soup.URI ("http://localhost/"));
		var response = new Response (request);

		try {
			router.handle (request, response);
		} catch (Error err) {
			assert_not_reached ();
		}

		assert (418 == response.status);
	});

	/**
	 * @since 0.1
	 */
	Test.add_func ("/router/connect", () => {
		var router = new Router ();

		router.connect ("/", (req, res) => {
			res.status = 418;
			return true;
		});

		var request  = new Request.with_method (VSGI.Request.CONNECT, new Soup.URI ("http://localhost/"));
		var response = new Response (request);

		try {
			router.handle (request, response);
		} catch (Error err) {
			assert_not_reached ();
		}

		assert (418 == response.status);
	});

	/**
	 * @since 0.1
	 */
	Test.add_func ("/router/patch", () => {
		var router = new Router ();

		router.patch ("/", (req, res) => {
			res.status = 418;
			return true;
		});

		var request  = new Request.with_method (VSGI.Request.PATCH, new Soup.URI ("http://localhost/"));
		var response = new Response (request);

		try {
			router.handle (request, response);
		} catch (Error err) {
			assert_not_reached ();
		}

		assert (418 == response.status);
	});

	/**
	 * @since 0.3
	 */
	Test.add_func ("/router/method_override", () => {
		var router = new Router ();

		router.patch ("/", (req, res) => {
			res.status = 418;
			return true;
		});

		var request  = new Request.with_method (VSGI.Request.POST, new Soup.URI ("http://localhost/"));
		var response = new Response (request);

		request.headers.append ("X-Http-Method-Override", "PATCH");

		try {
			router.handle (request, response);
		} catch (Error err) {
			assert_not_reached ();
		}

		assert (418 == response.status);
	});

	/**
	 * @since 0.3
	 */
	Test.add_func ("/router/named_route", () => {
		var router = new Router ();

		router.get ("/", (req, res, next, ctx) => { return true; }, "home");
		router.get ("/<int:i>", (req, res, next, ctx) => { return true; }, "foo");

		assert ("/" == router.url_for ("home"));
		assert ("/5" == router.url_for ("foo", "i", "5"));
	});

	/**
	 * @since 0.1
	 */
	Test.add_func ("/router/rule/wildcard", () => {
		var router  = new Router ();

		router.get ("*", (req, res, next, context) => {
			res.status = 418;
			return true;
		});

		var req = new Request.with_uri (new Soup.URI ("http://localhost/5"));
		var res = new Response (req);

		try {
			assert (router.handle (req, res));
		} catch (Error err) {
			assert_not_reached ();
		}

		assert (418 == res.status);
	});

	/**
	 * @since 0.1
	 */
	Test.add_func ("/router/rule/wildcard_matches_empty_path", () => {
		var router  = new Router ();

		router.get ("*", (req, res, next, context) => {
			res.status = 418;
			return true;
		});

		var req = new Request.with_uri (new Soup.URI ("http://localhost/"));
		var res = new Response (req);

		try {
			assert (router.handle (req, res));
		} catch (Error err) {
			assert_not_reached ();
		}

		assert (418 == res.status);
	});

	/**
	 * @since 0.3
	 */
	Test.add_func ("/router/rule/path", () => {
		var router  = new Router ();

		router.use (basic ());

		router.get ("<path:path>", (req, res, next, context) => {
			assert_not_reached ();
		});

		string[] bad_paths = {"..", "."};

		foreach (var bad_path in bad_paths) {
			var req = new Request.with_uri (new Soup.URI ("http://localhost/%s".printf (bad_path)));
			var res = new Response (req);

			try {
				assert (router.handle (req, res));
			} catch (Error err) {
				assert_not_reached ();
			}
		}
	});

	/**
	 * @since 0.1
	 */
	Test.add_func ("/router/rule/any", () => {
		var router  = new Router ();

		router.get ("*", (req, res, next, context) => {
			res.status = 418;
			return true;
		});

		var req = new Request.with_uri (new Soup.URI ("http://localhost/5"));
		var res = new Response (req);

		try {
			assert (router.handle (req, res));
		} catch (Error err) {
			assert_not_reached ();
		}
	});

	/**
	 * @since 0.1
	 */
	Test.add_func ("/router/regex", () => {
		var router = new Router ();

		router.regex (Method.GET, /\/home/, (req, res) => {
			res.status = 418;
			return true;
		});

		var route = router.routes.get_end_iter ().prev ().@get () as RegexRoute;

		assert ("^\\/home$" == route.regex.get_pattern ());
		assert (RegexCompileFlags.OPTIMIZE in route.regex.get_compile_flags ());

		var request  = new Request.with_uri (new Soup.URI ("http://localhost/home"));
		var response = new Response (request);

		try {
			router.handle (request, response);
		} catch (Error err) {
			assert_not_reached ();
		}

		assert (418 == response.status);
	});

	/**
	 * @since 0.3
	 */
	Test.add_func ("/router/path", () => {
		var router = new Router ();

		router.path (Method.GET, "/home", (req, res) => {
			res.status = 418;
			return true;
		});

		var route = router.routes.get_end_iter ().prev ().@get () as PathRoute;

		assert ("/home" == route.path);

		var request  = new Request.with_uri (new Soup.URI ("http://localhost/home"));
		var response = new Response (request);

		try {
			router.handle (request, response);
		} catch (Error err) {
			assert_not_reached ();
		}

		assert (418 == response.status);
	});

	/**
	 * @since 0.3
	 */
	Test.add_func ("/router/path/with_scope", () => {
		var router = new Router ();

		router.scope ("/admin", (admin) => {
			router.path (Method.GET, "/home", (req, res) => {
				res.status = 418;
				return true;
			});
		});

		var route = router.routes.get_end_iter ().prev ().@get () as PathRoute;

		assert ("/admin/home" == route.path);

		var request  = new Request.with_uri (new Soup.URI ("http://localhost/admin/home"));
		var response = new Response (request);

		try {
			router.handle (request, response);
		} catch (Error err) {
			assert_not_reached ();
		}

		assert (418 == response.status);
	});

	/**
	 * @since 0.1
	 */
	Test.add_func ("/router/matcher", () => {
		var router = new Router ();

		router.matcher (Method.GET, (req) => { return req.uri.get_path () == "/"; }, (req, res) => {
			res.status = 418;
			return true;
		});

		var request  = new Request.with_uri (new Soup.URI ("http://localhost/"));
		var response = new Response (request);

		try {
			router.handle (request, response);
		} catch (Error err) {
			assert_not_reached ();
		}

		assert (418 == response.status);
	});

	/**
	 * @since 0.1
	 */
	Test.add_func ("/router/scope", () => {
		var router = new Router ();

		router.scope ("/test", (inner) => {
			inner.get ("/test", (req, res) => {
				res.status = 418; // I'm a teapot
				return true;
			});
		});

		var request = new Request.with_uri (new Soup.URI ("http://localhost/test/test"));
		var response = new Response (request);

		try {
			router.handle (request, response);
		} catch (Error err) {
			assert_not_reached ();
		}

		assert (response.status == 418);
	});

	/**
	 * @since 0.1
	 */
	Test.add_func ("/router/scope/regex", () => {
		var router = new Router ();

		router.scope ("/test/", (test) => {
			test.regex (Method.GET, /(?<id>\d+)/, (req, res) => { return true; });
		});

		var route = router.routes.get_end_iter ().prev ().@get () as RegexRoute;

		var req     = new Request.with_uri (new Soup.URI ("http://localhost/test/5"));
		var context = new Context ();

		assert (route != null);
		assert (route.match (req, context));

		assert ("5" == context["id"].get_string ());
	});

	/**
	 * @since 0.1
	 */
	Test.add_func ("/router/informational/switching_protocols", () => {
		var router = new Router ();

		router.use (basic ());

		router.use ((req, res) => {
			throw new Informational.SWITCHING_PROTOCOLS ("HTTP/1.1");
		});

		var request  = new Request.with_uri (new Soup.URI ("http://localhost/"));
		var response = new Response (request);

		try {
			router.handle (request, response);
		} catch (Error err) {
			assert_not_reached ();
		}

		assert (response.status == Soup.Status.SWITCHING_PROTOCOLS);
		assert ("HTTP/1.1" == response.headers.get_one ("Upgrade"));
	});

	/**
	 * @since 0.1
	 */
	Test.add_func ("/router/success/created", () => {
		var router = new Router ();

		router.use (basic ());

		router.put ("/document", (req, res) => {
			throw new Success.CREATED ("/document/5");
		});

		var request  = new Request.with_method (VSGI.Request.PUT, new Soup.URI ("http://localhost/document"));
		var response = new Response (request);

		try {
			router.handle (request, response);
		} catch (Error err) {
			assert_not_reached ();
		}

		assert (Soup.Status.CREATED == response.status);
		assert ("/document/5" == response.headers.get_one ("Location"));
	});

	/**
	 * @since 0.1
	 */
	Test.add_func ("/router/success/partial_content", () => {
		var router = new Router ();

		router.use (basic ());

		router.put ("/document", (req, res) => {
			throw new Success.PARTIAL_CONTENT ("bytes 21010-47021/47022");
		});

		var request  = new Request.with_method (VSGI.Request.PUT, new Soup.URI ("http://localhost/document"));
		var response = new Response (request);

		try {
			router.handle (request, response);
		} catch (Error err) {
			assert_not_reached ();
		}

		assert (Soup.Status.PARTIAL_CONTENT == response.status);
		assert ("bytes 21010-47021/47022" == response.headers.get_one ("Range"));
	});

	/**
	 * @since 0.1
	 */
	Test.add_func ("/router/redirection", () => {
		var router = new Router ();

		router.use (basic ());

		router.get ("/", (req, res) => {
			throw new Redirection.MOVED_TEMPORARILY ("http://example.com");
		});

		var request = new Request.with_uri (new Soup.URI ("http://localhost/"));
		var response = new Response (request);

		try {
			router.handle (request, response);
		} catch (Error err) {
			assert_not_reached ();
		}

		assert (response.status == Soup.Status.MOVED_TEMPORARILY);
		assert ("http://example.com" == response.headers.get_one ("Location"));
	});

	/**
	 * @since 0.1
	 */
	Test.add_func ("/router/client_error/method_not_allowed", () => {
		var router = new Router ();

		router.use (basic ());

		router.post ("/", (req, res) => {
			return true;
		});

		router.use ((req, res) => {
			throw new ClientError.METHOD_NOT_ALLOWED ("POST");
		});

		var request  = new Request.with_uri (new Soup.URI ("http://localhost/"));
		var response = new Response (request);

		try {
			router.handle (request, response);
		} catch (Error err) {
			assert_not_reached ();
		}

		assert (Soup.Status.METHOD_NOT_ALLOWED == response.status);
		assert ("POST" == response.headers.get_one ("Allow"));
	});

	/**
	 * @since 0.1
	 */
	Test.add_func ("/router/client_error/upgrade_required", () => {
		var router = new Router ();

		router.use (basic ());

		router.use ((req, res) => {
			throw new ClientError.UPGRADE_REQUIRED ("HTTP/1.1");
		});

		var request  = new Request.with_uri (new Soup.URI ("http://localhost/"));
		var response = new Response (request);

		try {
			router.handle (request, response);
		} catch (Error err) {
			assert_not_reached ();
		}

		assert (426 == response.status);
		assert ("HTTP/1.1" == response.headers.get_one ("Upgrade"));
	});

	/**
	 * @since 0.1
	 */
	Test.add_func ("/router/server_error", () => {
		var router = new Router ();

		router.use (basic ());

		router.get ("/", (req, res) => {
			throw new ServerError.INTERNAL_SERVER_ERROR ("Teapot's burning!");
		});

		var request  = new Request.with_uri (new Soup.URI ("http://localhost/"));
		var response = new Response (request);

		try {
			router.handle (request, response);
		} catch (Error err) {
			assert_not_reached ();
		}

		var body = (MemoryOutputStream) request.connection.output_stream;
		HashTable<string, string> @params;

		assert (response.status == Soup.Status.INTERNAL_SERVER_ERROR);
		assert ("text/plain" == response.headers.get_content_type (out @params));
		assert ("charset" in @params);
		assert ("utf-8" == @params["charset"]);
		assert (17 == response.headers.get_content_length ());
		assert ("Teapot's burning!" in (string) body.get_data ());
	});

	/**
	 * @since 0.1
	 */
	Test.add_func ("/router/custom_method", () => {
		var router = new Router ();

		router.rule (Method.OTHER, "/", (req, res) => {
			res.status = 418;
			return true;
		});

		var request = new Request.with_method ("TEST", new Soup.URI ("http://localhost/"));
		var response = new Response (request);

		try {
			router.handle (request, response);
		} catch (Error err) {
			assert_not_reached ();
		}

		assert (response.status == 418);
	});

	/**
	 * @since 0.1
	 */
	Test.add_func ("/router/method_not_allowed", () => {
		var router = new Router ();

		router.use (basic ());

		router.get ("/", (req, res) => {
			return true;
		});

		router.put ("/", (req, res) => {
			return true;
		});

		var request = new Request.with_method ("POST", new Soup.URI ("http://localhost/"));
		var response = new Response.with_status (request, Soup.Status.METHOD_NOT_ALLOWED);

		try {
			router.handle (request, response);
		} catch (Error err) {
			assert_not_reached ();
		}

		assert (response.status == 405);
		assert ("GET, HEAD, PUT, TRACE" == response.headers.get_one ("Allow"));
	});

	/**
	 * @since 0.1
	 */
	Test.add_func ("/router/method_not_allowed/excludes_request_method", () => {
		var router = new Router ();

		var get_matched  = 0;
		var post_matched = 0;

		router.use (basic ());

		// matching, but not the same HTTP method
		router.matcher (Method.GET, () => { get_matched++; return true; }, (req, res) => {
			return true;
		});

		// not matching, but same HTTP method
		router.matcher (Method.POST, () => { post_matched++; return false; }, (req, res) => {
			return true;
		});

		var request = new Request.with_method ("POST", new Soup.URI ("http://localhost/"));
		var response = new Response.with_status (request, Soup.Status.METHOD_NOT_ALLOWED);

		try {
			router.handle (request, response);
		} catch (Error err) {
			assert_not_reached ();
		}

		assert (response.status == 405);
		assert ("GET, HEAD, TRACE" == response.headers.get_one ("Allow"));
	});


	Test.add_func ("/router/method_not_allowed/success_on_options", () => {
		var router = new Router ();

		router.use (basic ());

		router.get ("/", (req, res) => {
			return true;
		});

		router.put ("/", (req, res) => {
			return true;
		});

		var request = new Request.with_method ("OPTIONS", new Soup.URI ("http://localhost/"));
		var response = new Response.with_status (request, Soup.Status.METHOD_NOT_ALLOWED);

		try {
			router.handle (request, response);
		} catch (Error err) {
			assert_not_reached ();
		}

		assert (response.status == 200);
		assert ("GET, HEAD, PUT, TRACE" == response.headers.get_one ("Allow"));
		assert (Soup.Encoding.CONTENT_LENGTH == response.headers.get_encoding ());
		assert (0 == response.headers.get_content_length ());
	});

	/**
	 * @since 0.1
	 */
	Test.add_func ("/router/not_found", () => {
		var router = new Router ();

		router.use (basic ());

		var request = new Request.with_uri (new Soup.URI ("http://localhost/"));
		var response = new Response (request);

		try {
			router.handle (request, response);
		} catch (Error err) {
			assert_not_reached ();
		}

		assert (Soup.Status.NOT_FOUND == response.status);
	});


	/**
	 * @since 0.1
	 */
	Test.add_func ("/router/subrouting", () => {
		var router    = new Router ();
		var subrouter = new Router ();

		subrouter.get ("/", (req, res) => {
			res.status = 418;
			return true;
		});

		router.get ("/", subrouter.handle);

		var request = new Request.with_uri (new Soup.URI ("http://localhost/"));
		var response = new Response.with_status (request, Soup.Status.NOT_FOUND);

		try {
			router.handle (request, response);
		} catch (Error err) {
			assert_not_reached ();
		}

		assert (418 == response.status);
	});

	/**
	 * @since 0.1
	 */
	Test.add_func ("/router/next", () => {
		var router = new Router ();

		router.get ("/", (req, res, next) => {
			return next ();
		});

		// should recurse a bit in process_routing
		router.get ("/", (req, res, next) => {
			return next ();
		});

		router.get ("/", (req, res, next) => {
			res.status = 418;
			return true;
		});

		var request = new Request.with_uri (new Soup.URI ("http://localhost/"));
		var response = new Response.with_status (request, Soup.Status.NOT_FOUND);

		try {
			router.handle (request, response);
		} catch (Error err) {
			assert_not_reached ();
		}

		assert (418 == response.status);
	});

	Test.add_func ("/router/next/not_found", () => {
		var router = new Router ();

		router.use (basic ());

		router.get ("/", (req, res, next) => {
			return next ();
		});

		// should recurse a bit in process_routing
		router.get ("/", (req, res, next) => {
			return next ();
		});

		// no more route matching

		var request = new Request.with_uri (new Soup.URI ("http://localhost/"));
		var response = new Response (request);

		try {
			router.handle (request, response);
		} catch (Error err) {
			assert_not_reached ();
		}

		assert (404 == response.status);
	});

	/**
	 * @since 0.1
	 */
	Test.add_func ("/router/next/propagate_error", () => {
		var router = new Router ();

		router.get ("/", (req, res, next) => {
			try {
				return next ();
			} catch (ClientError.UNAUTHORIZED err) {
				res.status = err.code;
				return res.end ();
			}
		});

		router.get ("/", (req, res, next) => {
			return next ();
		});

		router.get ("/", (req, res, next) => {
			throw new ClientError.UNAUTHORIZED ("/");
		});

		var request = new Request.with_uri (new Soup.URI ("http://localhost/"));
		var response = new Response (request);

		try {
			router.handle (request, response);
		} catch (Error err) {
			assert_not_reached ();
		}

		assert (401 == response.status);
	});

	/**
	 * @since 0.1
	 */
	Test.add_func ("/router/next/propagate_state", () => {
		var router = new Router ();
		var state  = new Object ();

		router.get ("/", (req, res, next, context) => {
			context["state"] = state;
			return next ();
		});

		router.get ("/", (req, res, next) => {
			return next ();
		});

		router.get ("/", (req, res, next, context) => {
			res.status = 413;
			assert (state == context["state"]);
			return true;
		});

		var request = new Request.with_uri (new Soup.URI ("http://localhost/"));
		var response = new Response (request);

		try {
			router.handle (request, response);
		} catch (Error err) {
			assert_not_reached ();
		}

		assert (413 == response.status);
	});

	/**
	 * @since 0.1
	 */
	Test.add_func ("/router/next/replace_propagated_state", () => {
		var router = new Router ();
		var state  = new Object ();

		router.get ("/", (req, res, next, context) => {
			context["state"] = state;
			return next ();
		});

		router.get ("/", (req, res, next, context) => {
			assert (state == context["state"]);
			context["state"] = "something really different";
			return next ();
		});

		router.get ("/", (req, res, next, context) => {
			res.status = 413;
			assert (context["state"].holds (typeof (string)));
			assert (context.parent["state"].holds (typeof (string)));
			assert (context.parent.parent["state"].holds (typeof (Object)));
			return true;
		});

		var request = new Request.with_uri (new Soup.URI ("http://localhost/"));
		var response = new Response (request);

		try {
			router.handle (request, response);
		} catch (Error err) {
			assert_not_reached ();
		}

		assert (413 == response.status);
	});

	/**
	 * @since 0.2
	 */
	Test.add_func ("/router/then", () => {
		var router = new Router ();

		var setted      = false;
		var then_setted = false;

		router.get ("/<int:id>", sequence ((req, res, next) => {
			setted = true;
			return next ();
		}, (req, res) => {
			assert (setted);
			then_setted = true;
			return true;
		}));

		var req = new Request.with_uri (new Soup.URI ("http://localhost/5"));
		var res = new Response (req);

		try {
			assert (router.handle (req, res));
		} catch (Error err) {
			assert_not_reached ();
		}

		assert (setted);
		assert (then_setted);
	});

	/**
	  * @since 0.2.2
	  */
	Test.add_func ("/router/then/preserve_matching_context", () => {
		var router = new Router ();

		var reached = false;

		router.get ("/<int:id>", sequence ((req, res, next, context) => {
			context["test"] = "test";
			return next ();
		}, (req, res, next, context) => {
			reached = true;
			assert ("test" == context["test"].get_string ());
			assert ("5" == context["id"].get_string ());
			return true;
		}));

		var req = new Request.with_uri (new Soup.URI ("http://localhost/5"));
		var res = new Response (req);

		try {
			assert (router.handle (req, res));
		} catch (Error err) {
			assert_not_reached ();
		}

		assert (reached);
	});

	/**
	 * @since 0.2.1
	 */
	Test.add_func ("/router/error", () => {
		var router = new Router ();

		router.use ((req, res, next) => {
			try {
				return next ();
			} catch (IOError.FAILED err) {
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

		try {
			assert (router.handle (req, res));
		} catch (Error err) {
			assert_not_reached ();
		}

		assert (418 == res.status);
	});

	return Test.run ();
}
