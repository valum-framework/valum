using Gee;

namespace Valum {

	public const string APP_NAME = "Valum/0.1";
	
	public class Router {
		
		private HashMap<string, ArrayList<Route>> routes;
		private Soup.Server _server;
		private string[] _scope;

		public uint16 port;
		public string host;

		public delegate void NestedRouter(Valum.Router app);

		public Router() {
			this.port = 7777;
			this.host = "localhost";
			this.create_routes();
		}

		private void create_routes() {
			this.routes = new HashMap<string, ArrayList>();
			this.routes["GET"]  = new ArrayList<Route>();
			this.routes["POST"] = new ArrayList<Route>();
		}

		public int listen() {
			if (!Thread.supported()) {
				stderr.printf("Cannot run without threads.\n");
				return 1;
			}
			this._server = new Soup.Server (Soup.SERVER_PORT, this.port);
			this._server.add_handler ("/", this.request_handler);
			this._server.run ();
			return 0;
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
			this.routes[method].add(new Route(full_rule, cb));
		}

		// Handler code
		private void request_handler (Soup.Server server,
									  Soup.Message msg,
									  string path,
									  GLib.HashTable? query,
									  Soup.ClientContext client) {

#if (BENCHMARK)
			var timer  = new Timer();
			timer.start();
#endif
			
			var found  = false;
			var routes = this.routes[msg.method];

			foreach (var route in routes) {
				if (route.matches(path)) {
					var req = new Request(msg);
					var res = new Response(msg);
					route.fire(req, res);
#if (BENCHMARK)
					timer.stop();
					var elapsed = timer.elapsed();
					res.headers["X-Runtime"] = "%8.6f".printf(elapsed);
#endif
					res.send();
					found = true;
					break;
				}
			}
			
			
			if (!found) {
#if (BENCHMARK)
				timer.stop();
				timer.reset();
#endif
				print(@"Not found: $path\n");
			}
		}
	}
}
