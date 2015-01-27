using Gee;
using VSGI;

namespace Valum {

	public const string APP_NAME = "Valum/0.1";

	public class Router : GLib.Object, VSGI.Application {

		/**
		 * Registered types.
		 */
		public Map<string, string> types = new HashMap<string, string> ();

		/**
		 * Registered routes by HTTP method.
		 */
		private Map<string, Gee.List<Route>> routes = new HashMap<string, Gee.List<Route>> ();

		/**
		 * Stack of scope.
		 */
		private Gee.List<string> scopes = new ArrayList<string> ();

		public delegate void NestedRouter (Valum.Router app);

		public Router () {

			// initialize default types
			this.types["int"]    = "\\d+";
			this.types["string"] = "\\w+";
			this.types["any"]    = ".+";

			this.handler.connect ((req, res) => {
				res.status = 200;
				res.mime   = "text/html";
			});

			this.handler.connect_after((req, res) => {
				res.close ();
			});
		}

		//
		// HTTP Verbs
		//
		public new void get (string rule, Route.RouteCallback cb) {
			this.method (Request.GET, rule, cb);
		}

		public void post (string rule, Route.RouteCallback cb) {
			this.method (Request.POST, rule, cb);
		}

		public void put (string rule, Route.RouteCallback cb) {
			this.method (Request.PUT, rule, cb);
		}

		public void delete (string rule, Route.RouteCallback cb) {
			this.method (Request.DELETE, rule, cb);
		}

		public void head (string rule, Route.RouteCallback cb) {
			this.method (Request.HEAD, rule, cb);
		}

		public void options(string rule, Route.RouteCallback cb) {
			this.method (Request.OPTIONS, rule, cb);
		}

		public void trace (string rule, Route.RouteCallback cb) {
			this.method (Request.TRACE, rule, cb);
		}

		public new void connect (string rule, Route.RouteCallback cb) {
			this.method (Request.CONNECT, rule, cb);
		}

		// http://tools.ietf.org/html/rfc5789
		public void patch (string rule, Route.RouteCallback cb) {
			this.method (Request.PATCH, rule, cb);
		}

		/**
		 * Bind a callback with a custom method.
         *
		 * Useful if you need to support a non-standard HTTP method, otherwise you
		 * should use the predefined methods.
		 *
		 * @param method HTTP method
		 * @param rule   rule
		 * @param cb     callback to be called on request matching the method and the
		 *               rule.
		 */
		public void method (string method, string rule, Route.RouteCallback cb) {
			var full_rule = new StringBuilder ();

			// scope the route
			foreach (var scope in this.scopes) {
				full_rule.append ("/%s".printf (scope));
			}

			full_rule.append ("/%s".printf(rule));

			this.route (method, new Route.from_rule (this, full_rule.str, cb));
		}

		/**
		 * Bind a callback with a custom method and regular expression.
         *
		 * It is recommended to declare the Regex using the RegexCompileFlags.OPTIMIZE
		 * flag as it will be used *very* often during the application process.
         *
		 * @param method HTTP method
		 * @param regex  regular expression matching the request path.
		 */
		public void regex (string method, Regex regex, Route.RouteCallback cb) {
			this.route (method, new Route.from_regex (this, regex, cb));
		}

		/**
		 * Bind a callback with a custom method and matcher.
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
			if (!this.routes.has_key(method)){
				this.routes[method] = new ArrayList<Route> ();
			}

			this.routes[method].add (route);
		}

		/**
		 * Add a fragment to the scope stack and nest a router in this
		 * new environment.
		 *
		 * Scoping will only work with rules
		 *
		 * @param fragment fragment to push on the scopes stack
		 * @param router   nested router in the new scoped environment
		 */
		public void scope (string fragment, NestedRouter router) {
			this.scopes.add (fragment);
			router (this);
			this.scopes.remove_at (this.scopes.size - 1);
		}

		/**
		 * Signal handling the request.
		 *
		 * It is possible to bind a callback to be executed before and after
		 * this signal so that you can have setup and teardown operations (ex.
		 * closing the database connection, sending mails).
		 *
		 * @param req request being handled.
		 * @param res response being transmitted to the request client.
		 */
		public void handler (Request req, Response res) {

			info ("%s %s".printf (req.method, req.uri.get_path ()));

			var routes = this.routes[req.method];

			foreach (var route in routes) {
				if (route.match (req)) {

					// fire the route!
					route.fire (req, res);

					return;
				}
			}
		}
	}
}
