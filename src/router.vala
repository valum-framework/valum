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
		private Map<string, Gee.List<Route>> routes = new HashMap<string, Gee.List> ();

		/**
		 * Stack of scope.
		 */
		private Gee.List<string> scopes = new ArrayList<string> ();

		public delegate void NestedRouter (Valum.Router app);

		public Router () {

			// initialize default types
			this.types["int"]    = "\\d+";
			this.types["string"] = "\\w+";

			this.handler.connect ((req, res) => {
				res.status = 200;
				res.mime   = "text/html";
			});

			this.handler.connect_after((req, res) => {
				res.close ();
			});

#if (BENCHMARK)
			var timer  = new Timer();

			this.handler.connect ((req, res) => {
				timer.start();
			});

			this.handler.connect_after ((req, res) => {
				timer.stop();
				var elapsed = timer.elapsed();
				res.headers.append("X-Runtime", "%8.3fms".printf(elapsed * 1000));
				message ("%s computed in %8.3fms", req.path, elapsed * 1000);
			});
#endif
		}

		//
		// HTTP Verbs
		//
		public new void get(string rule, Route.RouteCallback cb) {
			this.route("GET", rule, cb);
		}

		public void post(string rule, Route.RouteCallback cb) {
			this.route("POST", rule, cb);
		}

		public void put(string rule, Route.RouteCallback cb) {
			this.route("PUT", rule, cb);
		}

		public void delete(string rule, Route.RouteCallback cb) {
			this.route("DELETE", rule, cb);
		}

		public void head(string rule, Route.RouteCallback cb) {
			this.route("HEAD", rule, cb);
		}

		public void options(string rule, Route.RouteCallback cb) {
			this.route("OPTIONS", rule, cb);
		}

		public void trace(string rule, Route.RouteCallback cb) {
			this.route("TRACE", rule, cb);
		}

		public new void connect(string rule, Route.RouteCallback cb) {
			this.route("CONNECT", rule, cb);
		}

		// http://tools.ietf.org/html/rfc5789
		public void patch(string rule, Route.RouteCallback cb) {
			this.route("PATCH", rule, cb);
		}


		//
		// Routing helpers
		//
		public void scope (string fragment, NestedRouter router) {
			this.scopes.add (fragment);
			router (this);
			this.scopes.remove_at (this.scopes.size - 1);
		}

		//
		// Routing and request handling machinery
		//
		private void route(string method, string rule, Route.RouteCallback cb) {
			var full_rule = new StringBuilder();

			// scope the route
			foreach (var scope in this.scopes)
			{
				full_rule.append ("/%s".printf (scope));
			}

			full_rule.append ("/%s".printf(rule));

			// initialize the method if no route were registered
			if (!this.routes.has_key(method)){
				this.routes[method] = new ArrayList<Route> ();
			}

			this.routes[method].add (new Route.from_rule (this, full_rule.str, cb));
		}

		/**
		 * Signal handling the request.
         *
		 * It is possible to bind a callback to be executed before and after
		 * this signal so that you can have setup and teardown operations (ex.
		 * closing the database connection, sending mails).
		 */
		public void handler (Request req, Response res) {
			var routes = this.routes[req.method];

			foreach (var route in routes) {
				if (route.matches(req.uri.get_path ())) {

					// fire the route!
					route.fire (req, res);

					return;
				}
			}
		}
	}
}
