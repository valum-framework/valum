using GLib;
using VSGI;

[CCode (gir_namespace = "Valum", gir_version = "0.1")]
namespace Valum {

	/**
	 * Dispatches incoming requests to the appropriate registered handler.
	 *
	 * @since 0.0.1
	 */
	public class Router : Object, VSGI.Application {

		/**
		 * Registered types used to extract {@link VSGI.Request} parameters.
         *
		 * @since 0.1
		 */
		public HashTable<string, Regex> types = new HashTable<string, Regex> (str_hash, str_equal);

		/**
		 * Registered routes by HTTP method.
		 */
		private HashTable<string, Queue<Route>> routes = new HashTable<string, Queue<Route>> (str_hash, str_equal);

		/**
		 * Stack of scopes.
		 *
		 * @since 0.1
		 */
		public Queue<string> scopes = new Queue<string> ();

		/**
		 * Loads {@link Route} instances on a provided router.
		 *
		 * This is used for scoping and as a general definition for callback
		 * taking a {@link Router} as parameter like modules.
		 *
		 * @since 0.0.1
		 */
		public delegate void Loader (Valum.Router router);

		/**
		 * Keeps routing the {@link VSGI.Request} and {@link VSGI.Response}.
		 *
		 * @since 0.1
		 */
		public delegate void Next () throws Redirection, ClientError, ServerError;

		/**
		 * Teardown a request after it has been processed even if a
		 * {@link Redirection}, {@link ClientError} or {@link ServerError} is
		 * thrown during the handling.
		 *
		 * @since 0.1
		 */
		public signal void teardown (Request req, Response res);

		/**
		 * @since 0.0.1
		 */
		public Router () {
			// initialize default types
			this.types["int"]    = /\d+/;
			this.types["string"] = /\w+/;
			this.types["path"]   = /[\w\/]+/;
			this.types["any"]    = /.+/;
		}

		/**
		 * @since 0.0.1
		 */
		public new void get (string rule, Route.Handler cb) throws RegexError {
			this.method (Request.GET, rule, cb);
		}

		/**
		 * @since 0.0.1
		 */
		public void post (string rule, Route.Handler cb) throws RegexError {
			this.method (Request.POST, rule, cb);
		}

		/**
		 * @since 0.0.1
		 */
		public void put (string rule, Route.Handler cb) throws RegexError {
			this.method (Request.PUT, rule, cb);
		}

		/**
		 * @since 0.0.1
		 */
		public void delete (string rule, Route.Handler cb) throws RegexError {
			this.method (Request.DELETE, rule, cb);
		}

		/**
		 * @since 0.0.1
		 */
		public void head (string rule, Route.Handler cb) throws RegexError {
			this.method (Request.HEAD, rule, cb);
		}

		/**
		 * @since 0.0.1
		 */
		public void options(string rule, Route.Handler cb) throws RegexError {
			this.method (Request.OPTIONS, rule, cb);
		}

		/**
		 * @since 0.0.1
		 */
		public void trace (string rule, Route.Handler cb) throws RegexError {
			this.method (Request.TRACE, rule, cb);
		}

		/**
		 * @since 0.0.1
		 */
		public new void connect (string rule, Route.Handler cb) throws RegexError {
			this.method (Request.CONNECT, rule, cb);
		}

		/**
		 * [[http://tools.ietf.org/html/rfc5789]]
		 *
		 * @since 0.0.1
		 */
		public void patch (string rule, Route.Handler cb) throws RegexError {
			this.method (Request.PATCH, rule, cb);
		}

		/**
		 * Bind a callback with a custom HTTP method and a rule.
		 *
		 * Useful if you need to support a non-standard HTTP method, otherwise you
		 * should use the predefined methods.
		 *
		 * @since 0.1
		 *
		 * @param method HTTP method
		 * @param rule   rule
		 * @param cb     callback used to process the pair of request and response.
		 */
		public void method (string method, string rule, Route.Handler cb) throws RegexError {
			this.route (method, new Route.from_rule (this, rule, cb));
		}

		/**
		 * Bind a callback with a custom HTTP method and regular expression.
		 *
		 * The regular expression will be scoped, anchored and optimized by the
		 * {@link Route} automatically.
		 *
		 * @since 0.1
		 *
		 * @param method HTTP method
		 * @param regex  regular expression matching the request path.
		 * @param cb     callback used to process the pair of request and response.
		 */
		public void regex (string method, Regex regex, Route.Handler cb) throws RegexError {
			this.route (method, new Route.from_regex (this, regex, cb));
		}

		/**
		 * Bind a callback with a custom HTTP method and a matcher callback.
		 *
		 * @since 0.1
		 *
		 * @param method  HTTP method
		 * @param matcher callback used to match the request
		 * @param cb      callback used to process the pair of request and response.
		 */
		public void matcher (string method, Route.Matcher matcher, Route.Handler cb) {
			this.route (method, new Route (this, matcher, cb));
		}

		/**
		 * Bind a {@link Route} to a custom HTTP method.
		 *
		 * This is a low-level function and should be used with care.
		 *
		 * @param method HTTP method
		 * @param route  an instance of Route defining the matching process and the
		 *               callback.
		 */
		private void route (string method, Route route) {
			if (!this.routes.contains (method))
				this.routes[method] = new Queue<Route> ();

			this.routes[method].push_tail (route);
		}

		/**
		 * Add a fragment to the scope stack and nest a router in this new
		 * environment.
		 *
		 * Scoping will only work with rules and regular expressions.
		 *
		 * @since 0.0.1
		 *
		 * @param fragment fragment to push on the scopes stack
		 * @param loader   nests a router in the new scoped environment
		 */
		public void scope (string fragment, Loader loader) {
			this.scopes.push_tail (fragment);
			loader (this);
			this.scopes.pop_tail ();
		}

		/**
		 * Perform the routing given a specific list of routes.
		 *
		 * @param routes
		 * @param req
		 * @param res
		 * @return tells if something matched during the routing process
		 */
		private bool perform_routing (List<Route> routes, Request req, Response res) throws Redirection, ClientError, ServerError {
			foreach (var route in routes) {
				if (route.match (req)) {
					route.fire (req, res, () => {
						unowned List<Route> current = routes.find (route);
						// keep routing if there are more routes to explore
						if (current.next != null)
							if (perform_routing (current.next, req, res))
								return;
						throw new ClientError.NOT_FOUND ("The request URI %s was not found.".printf (req.uri.to_string (false)));
					});
					return true;
				}
			}
			return false;
		}

		/**
		 * {@inheritDoc}
		 *
		 * The response is initialized with sane default such as 200 status
		 * code, 'text/html' content type and request cookies.
		 */
		public void handle (Request req, Response res) {
			// sane initialization
			res.status = Soup.Status.OK;
			res.headers.set_content_type ("text/html", null);
			res.cookies = req.cookies;

			try {
				// ensure at least one route has been declared with that method
				if (this.routes.contains (req.method)) {
					// find a route that may handle the request
					if (this.perform_routing (this.routes[req.method].head, req, res))
						return; // something matched
				}

				// find routes from other methods matching this Request
				var allowed = new StringBuilder ();
				foreach (var method in this.routes.get_keys ()) {
					foreach (var route in this.routes[method].head) {
						if (route.match (req)) {
							if (allowed.len > 0)
								allowed.append (", ");
							allowed.append (method);
							break;
						}
					}
				}

				// a Route from another method allows this Request
				if (allowed.len > 0) {
					throw new ClientError.METHOD_NOT_ALLOWED (allowed.str);
				}

				throw new ClientError.NOT_FOUND ("The request URI %s was not found.".printf (req.uri.to_string (false)));

			} catch (Redirection r) {
				res.status = r.code;
				res.headers.append("Location", r.message);
			} catch (ClientError.METHOD_NOT_ALLOWED e) {
				res.status = e.code;
				res.headers.append ("Allow", e.message);
			} catch (ClientError e) {
				res.status = e.code;
			} catch (ServerError e) {
				res.status = e.code;
			} finally {
				teardown (req, res);
			}
		}
	}
}
