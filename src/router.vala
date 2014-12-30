using Gee;

namespace Valum {

	public const string APP_NAME = "Valum/0.1";

	public class Router {

		// list of routes associated to each HTTP method
		private HashMap<string, ArrayList<Route>> routes = new HashMap<string, ArrayList> ();

		private string[] scopes;

		public delegate void NestedRouter(Valum.Router app);

		public Router() {

			this.handler.connect((req, res) => {
				res.status = 200;
				res.mime   = "text/html";
			});

			this.handler.connect_after((req, res) => {
				res.body.close ();
			});

#if (BENCHMARK)
			var timer  = new Timer();

			this.handler.connect((req, res) => {
				timer.start();
			});

			this.handler.connect_after((req, res) => {
				timer.stop();
				var elapsed = timer.elapsed();
				res.headers["X-Runtime"] = "%8.3fms".printf(elapsed * 1000);
				message("%s computed in %8.3fms", req.path, elapsed * 1000);
			});
#endif
		}

		//
		// HTTP Verbs
		//
		public new void get(string rule, Route.RequestCallback cb) {
			this.route("GET", rule, cb);
		}

		public void post(string rule, Route.RequestCallback cb) {
			this.route("POST", rule, cb);
		}

		public void put(string rule, Route.RequestCallback cb) {
			this.route("PUT", rule, cb);
		}

		public void delete(string rule, Route.RequestCallback cb) {
			this.route("DELETE", rule, cb);
		}

		public void head(string rule, Route.RequestCallback cb) {
			this.route("HEAD", rule, cb);
		}

		public void options(string rule, Route.RequestCallback cb) {
			this.route("OPTIONS", rule, cb);
		}

		public void trace(string rule, Route.RequestCallback cb) {
			this.route("TRACE", rule, cb);
		}

		public void connect(string rule, Route.RequestCallback cb) {
			this.route("CONNECT", rule, cb);
		}

		// http://tools.ietf.org/html/rfc5789
		public void patch(string rule, Route.RequestCallback cb) {
			this.route("PATCH", rule, cb);
		}


		//
		// Routing helpers
		//
		public void scope(string fragment, NestedRouter router) {
			this.scopes += fragment;
			router(this);
			this.scopes = this.scopes[0:-1];
		}

		//
		// Routing and request handling machinery
		//
		private void route(string method, string rule, Route.RequestCallback cb) {
			string full_rule = "";

			foreach (var scope in this.scopes) {
				full_rule += "/%s".printf(scope);
			}

			full_rule += "/%s".printf(rule);

			// initialize the method if no route were registered
			if (!this.routes.has_key(method)){
				this.routes[method] = new ArrayList<Route> ();
			}

			this.routes[method].add(new Route(full_rule, cb));
		}

		// handler code
		public virtual signal void handler (Request req, Response res) {
			var routes = this.routes[req.method];

			foreach (var route in routes) {
				if (route.matches(req.path)) {

					// fire the route!
					route.fire (req, res);

					return;
				}
			}
		}

		// libsoup based handler
		public void soup_handler (Soup.Server server,
				Soup.Message msg,
				string path,
				GLib.HashTable? query,
				Soup.ClientContext client) {

			var req = new SoupRequest(msg);
			var res = new SoupResponse(msg);

			this.handler (req, res);
		}

		//public void fastcgi_request_handler (FastCGI.request request) {
			// TODO: implementation

			//var req = new FastCGIRequest(request);
			//var res = new FastCGIResponse ();

			//this.request_handler (req, res);
		//}
	}

}


