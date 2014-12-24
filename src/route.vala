using Gee;

namespace Valum {
	
	public class Route : Object {
		public  string rule;
		private string route;
		private Regex regex;
		private ArrayList<string> captures;
		public delegate void RequestCallback(Request req, Response res);
		private unowned RequestCallback cb;
			
		public Route(string rule, RequestCallback cb) {
			this.cb = cb;
			this.rule = rule;
			this.captures = new ArrayList<string>();
				
			try {
				Regex param_re = new Regex("(<((int|float):)?\\w+>)");
				var params = param_re.split_full(this.rule);
				
				StringBuilder route = new StringBuilder("^");
					
				foreach(var p in params) {
					if(p[0] != '<') {
						// regular piece of route
						route.append(p);
					} else {
						// parameter
						var cap = p.slice(1, p.length - 1).split(":", 2);
						var type = cap.length == 1 ? "string" : cap[0];
						var key = cap.length == 1 ? cap[0] : cap[1];
						print("registered key %s with type %s\n".printf(key, type));
						// TODO: enfoce type with a specfic regex
						captures.add(key);
						route.append(@"(?<$key>\\w+)");
					}
				}
      
				route.append("$");
					
				this.route = route.str;
				this.regex = new Regex(route.str, RegexCompileFlags.OPTIMIZE);
			} catch(RegexError e) {
				stderr.printf("Route.new(): %s\n", e.message);
			}
		}
			
		public bool matches(string path) {
			return this.regex.match(path, 0);
		}

		public void fire(Request req, Response res) {
			MatchInfo matchinfo;
			if(this.regex.match(req.path, 0, out matchinfo)) {
				foreach(var cap in captures) {
					req.params[cap] = matchinfo.fetch_named(cap);
				}
			}
			this.cb(req, res);
		}
	}
}
