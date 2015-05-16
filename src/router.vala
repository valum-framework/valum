using VSGI;

[CCode (gir_namespace = "Valum", gir_version = "0.1")]
namespace Valum {

	/**
	 * @since 0.0.1
	 */
	public class Router : GLib.Object, VSGI.Application {

		/**
		 * Registered types.
         *
		 * @since 0.1
		 */
		public HashTable<string, Regex> types = new HashTable<string, Regex> (str_hash, str_equal);

		/**
		 * Registered routes by HTTP method.
		 */
		private HashTable<string, Queue<Route>> routes = new HashTable<string, Queue<Route>> (str_hash, str_equal);

		/**
		 * Stack of scope.
		 *
		 * @since 0.1
		 */
		public Queue<string> scopes = new Queue<string> ();

		/**
		 * Loads route on a providen router.
		 *
		 * @since 0.0.1
		 */
		public delegate void Loader (Valum.Router router);

		/**
		 * Signal called before a request is being processed.
		 */
		public virtual signal void setup (Request req, Response res) {
			res.status = Soup.Status.OK;
			res.headers.set_content_type ("text/html", null);

			// filter and transmit cookies from request to response
			var cookies = req.cookies;
			var kept    = new SList<Soup.Cookie> ();

			foreach (var cookie in cookies) {
				// filter expired or unapplying cookies
				if (cookie.domain_matches (req.uri.get_host ()) && cookie.applies_to_uri (req.uri) && !cookie.expires.is_past ()) {
					kept.prepend (cookie);
				}
			}

			kept.reverse ();

			res.cookies = kept;
		}

		/**
		 * Called after a request has been processed.
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
		 * @since 0.0.1
		 * @url   http://tools.ietf.org/html/rfc5789
		 */
		public void patch (string rule, Route.Handler cb) throws RegexError {
			this.method (Request.PATCH, rule, cb);
		}

		/**
		 * Bind a callback with a custom method.
         *
		 * Useful if you need to support a non-standard HTTP method, otherwise you
		 * should use the predefined methods.
		 *
		 * @since 0.1
		 *
		 * @param method HTTP method
		 * @param rule   rule
		 * @param cb     callback to be called on request matching the method and the
		 *               rule.
		 */
		public void method (string method, string rule, Route.Handler cb) throws RegexError {
			this.route (method, new Route.from_rule (this, rule, cb));
		}

		/**
		 * Bind a callback with a custom method and regular expression.
         *
		 * It is recommended to declare the Regex using the RegexCompileFlags.OPTIMIZE
		 * flag as it will be used *very* often during the application process.
         *
		 * @since 0.1
		 *
		 * @param method HTTP method
		 * @param regex  regular expression matching the request path.
		 */
		public void regex (string method, Regex regex, Route.Handler cb) throws RegexError {
			this.route (method, new Route.from_regex (this, regex, cb));
		}

		/**
		 * Bind a callback with a custom method and matcher.
		 *
		 * @since 0.1
		 */
		public void matcher (string method, Route.Matcher matcher, Route.Handler cb) {
			this.route (method, new Route (this, matcher, cb));
		}

		/**
		 * Bind a callback with a custom method and route.
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
		 * Add a fragment to the scope stack and nest a router in this
		 * new environment.
		 *
		 * Scoping will only work with rules
		 *
		 * @since 0.0.1
		 *
		 * @param fragment fragment to push on the scopes stack
		 * @param router   nested router in the new scoped environment
		 */
		public void scope (string fragment, Loader loader) {
			this.scopes.push_tail (fragment);
			loader (this);
			this.scopes.pop_tail ();
		}

		/**
		 * Signal handling the request.
		 *
		 * It is possible to bind a callback to be executed before and after
		 * this signal so that you can have setup and teardown operations (ex.
		 * closing the database connection, sending mails).
		 *
		 * @since 0.1
		 *
		 * @param req request being handled.
		 * @param res response being transmitted to the request client.
		 */
		public async void handle (Request req, Response res) {
			setup (req, res);

			try {
				// ensure at least one route has been declared with that method
				if (this.routes.contains(req.method)) {
					// find a route that may handle the request
					foreach (var route in this.routes[req.method].head) {
						if (route.match (req)) {
							route.fire (req, res);
							return;
						}
					}
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
			}

			teardown (req, res);
		}
	}
}
