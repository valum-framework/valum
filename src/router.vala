using Gee;

namespace Valum {

	public const string APP_NAME = "Valum/0.1";

	public class Router {

		private HashMap<string, ArrayList<Route>> routes = new HashMap<string, ArrayList> ();
		private string[] _scope;

		// signal called before a request execution starts
		public signal void before_request (Request req, Response res);

		// signal called after a request has executed
		public signal void after_request (Request req, Response res);

		public delegate void NestedRouter(Valum.Router app);

		public Router() {

			// complete the response body
			this.after_request.connect((req, res) => {
				res.message.response_body.complete ();
			});

#if (BENCHMARK)
			var timer  = new Timer();

			this.before_request.connect((req, res) => {
				timer.start();
			});

			this.after_request.connect((req, res) => {
				timer.stop();
				var elapsed = timer.elapsed();
				res.headers.append("X-Runtime", "%8.3fms".printf(elapsed * 1000));
			});
#endif

			// initialize the Response object
			this.before_request.connect((req, res) => {
				res.status = 200;
				res.mime = "text/html";
			});
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
			this._scope += fragment;
			router(this);
			this._scope = this._scope[0:-1];
		}

		//
		// Routing and request handling machinery
		//
		private void route(string method, string rule, Route.RequestCallback cb) {
			string full_rule = "";
			for (var seg = 0; seg < this._scope.length; seg++) {
				full_rule += "/";
				full_rule += this._scope[seg];
			}
			full_rule += "/%s".printf(rule);
			if (!this.routes.has_key(method)){
				this.routes[method] = new ArrayList<Route> ();
			}
			this.routes[method].add(new Route(full_rule, cb));
		}

		// Handler code
		public void request_handler (Soup.Server server,
				Soup.Message msg,
				string path,
				GLib.HashTable? query,
				Soup.ClientContext client) {

			var req = new Request(msg);
			var res = new Response(msg);

			this.before_request (req, res);

			var routes = this.routes[msg.method];

			foreach (var route in routes) {
				if (route.matches(path)) {

					// fire the route!
					route.fire(req, res);

					this.after_request (req, res);

					return;
				}
			}

			// No route has matched
			stderr.printf("Could not match %s.\n", path);
			res.status = 404;
			res.mime = "text/plain";
			res.append("The requested URL %s was not found.".printf(path));

			this.after_request (req, res);
		}
	}

}


