using VSGI;

namespace Valum {

	/**
	 * @since 0.0.1
	 */
	public const string APP_NAME = "Valum/0.1";

	/**
	 * @since 0.0.1
	 */
	public class Router : GLib.Object, VSGI.Application {

		/**
		 * Registered types.
         *
		 * @since 0.1
		 */
		public HashTable<string, string> types = new HashTable<string, string> (str_hash, str_equal);

		/**
		 * Base path of the running application.
		 */
		private string base_path = "/";

		/**
		 * Registered routes by HTTP method.
		 */
		private HashTable<string, Queue<Route>> routes = new HashTable<string, Queue<Route>> (str_hash, str_equal);

		/**
		 * Stack of scope.
		 */
		private Queue<string> scopes = new Queue<string> ();

		/**
		 * @since 0.0.1
		 */
		public delegate void NestedRouter (Valum.Router app);

		/**
		 * @since 0.0.1
		 */
		public Router (string base_path = "/") {
			this.base_path = base_path;

			// initialize default types
			this.types["int"]    = "\\d+";
			this.types["string"] = "\\w+";
			this.types["path"]   = "[\\w/]+";
			this.types["any"]    = ".+";

			this.handler.connect ((req, res) => {
				res.status = 200;
				res.headers.set_content_type ("text/html", null);
			});

			this.handler.connect_after ((req, res) => {
				res.close ();
			});
		}

		/**
		 * @since 0.0.1
		 */
		public new void get (string rule, Route.RouteCallback cb) throws RegexError {
			this.method (Request.GET, rule, cb);
		}

		/**
		 * @since 0.0.1
		 */
		public void post (string rule, Route.RouteCallback cb) throws RegexError {
			this.method (Request.POST, rule, cb);
		}

		/**
		 * @since 0.0.1
		 */
		public void put (string rule, Route.RouteCallback cb) throws RegexError {
			this.method (Request.PUT, rule, cb);
		}

		/**
		 * @since 0.0.1
		 */
		public void delete (string rule, Route.RouteCallback cb) throws RegexError {
			this.method (Request.DELETE, rule, cb);
		}

		/**
		 * @since 0.0.1
		 */
		public void head (string rule, Route.RouteCallback cb) throws RegexError {
			this.method (Request.HEAD, rule, cb);
		}

		/**
		 * @since 0.0.1
		 */
		public void options(string rule, Route.RouteCallback cb) throws RegexError {
			this.method (Request.OPTIONS, rule, cb);
		}

		/**
		 * @since 0.0.1
		 */
		public void trace (string rule, Route.RouteCallback cb) throws RegexError {
			this.method (Request.TRACE, rule, cb);
		}

		/**
		 * @since 0.0.1
		 */
		public new void connect (string rule, Route.RouteCallback cb) throws RegexError {
			this.method (Request.CONNECT, rule, cb);
		}

		/**
		 * @since 0.0.1
		 * @url   http://tools.ietf.org/html/rfc5789
		 */
		public void patch (string rule, Route.RouteCallback cb) throws RegexError {
			this.method (Request.PATCH, rule, cb);
		}

		/**
		 * Bind a callback with a custom method.
         *
		 * The providen rule will be scoped based on the current scopes stack by
		 * prepending /<scope>.
		 *
		 * Useful if you need to support a non-standard HTTP method, otherwise you
		 * should use the predefined methods.
         *
		 * All prefedined methods are calling this function.
		 *
		 * @since 0.1
		 *
		 * @param method HTTP method
		 * @param rule   rule
		 * @param cb     callback to be called on request matching the method and the
		 *               rule.
		 */
		public void method (string method, string rule, Route.RouteCallback cb) throws RegexError {
			var full_rule = new StringBuilder ();

			// scope the route
			foreach (var scope in this.scopes.head) {
				full_rule.append ("/%s".printf (scope));
			}

			// rebase the rule
			full_rule.append ("%s%s".printf(this.base_path, rule));

			this.route (method, new Route.from_rule (this, full_rule.str, cb));
		}

		/**
		 * Bind a callback with a custom method and regular expression.
         *
		 * It is recommended to declare the Regex using the RegexCompileFlags.OPTIMIZE
		 * flag as it will be used *very* often during the application process.
		 *
		 * Regex are unaware of the base_path parameter, so if you specify one, you
		 * will have to prefix your regular expression manually.
         *
		 * @since 0.1
		 *
		 * @param method HTTP method
		 * @param regex  regular expression matching the request path.
		 */
		public void regex (string method, Regex regex, Route.RouteCallback cb) throws RegexError {
			this.route (method, new Route.from_regex (this, regex, cb));
		}

		/**
		 * Bind a callback with a custom method and matcher.
		 *
		 * @since 0.1
		 */
		public void matcher (string method, Route.RequestMatcher matcher, Route.RouteCallback cb) {
			this.route (method, new Route.from_matcher (this, matcher, cb));
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
		public void scope (string fragment, NestedRouter router) {
			this.scopes.push_tail (fragment);
			router (this);
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
		public void handler (Request req, Response res) {
			// ensure at least one route has been declared with that method
			if (!this.routes.contains(req.method))
				return;

			foreach (var route in this.routes[req.method].head) {
				if (route.match (req)) {

					// fire the route!
					route.fire (req, res);

					return;
				}
			}
		}
	}
}
