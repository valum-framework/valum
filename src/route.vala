using Gee;

namespace Valum {

	/**
	 * Route that matches Request path.
	 */
	public class Route : Object {

		/**
		 * Router that declared this route.
		 */
		private weak Router router;

		/**
		 * Match a Request and populate its parameters if successful.
		 */
		private RequestMatcher matcher;

		/**
		 * Callback
		 */
		private unowned RequestCallback callback;

		/**
		 * Match the request and populate the parameters.
		 */
		public delegate bool RequestMatcher (Request req);

		public delegate void RequestCallback (Request req, Response res);

		/**
		 * Create a Route using a custom matcher.
		 */
		public Route.from_matcher (Router router, RequestMatcher matcher, RequestCallback callback) {
			this.router   = router;
			this.matcher  = matcher;
			this.callback = callback;
		}

		/**
		 * Create a Route for a given callback using a Regex.
		 */
		public Route.from_regex (Router router, Regex regex, RequestCallback callback) {
			this.router   = router;
			this.callback = callback;

			var captures      = new ArrayList<string> ();
			var capture_regex = new Regex ("\\(\\?<(\\w+)>.+\\)");
			MatchInfo capture_match_info;

			// extract the captures from the regular expression
			if (capture_regex.match (regex.get_pattern (), 0, out capture_match_info)) {
				foreach (var capture in capture_match_info.fetch_all ()) {
					message ("found capture %s in regex %s".printf (capture, regex.get_pattern ()));
					captures.add (capture);
				}
			}

			this.matcher = (req) => {
				MatchInfo match_info;
				if (regex.match (req.path, 0, out match_info)) {
					// populate the request parameters
					foreach (var capture in captures) {
						req.params[capture] = match_info.fetch_named (capture);
					}
					return true;
				}
				return false;
			};
		}

		/**
		 * Create a Route for a given callback from a rule.
         *
		 * A rule will compile down to Regex.
		 */
		public Route.from_rule (Router router, string rule, RequestCallback callback) {
			this.router   = router;
			this.callback = callback;

			var param_regex = new Regex ("(<(?:\\w+:)?\\w+>)");
			var params      = param_regex.split_full (rule);
			var captures    = new ArrayList<string> ();
			var route       = new StringBuilder ("^");

			foreach (var p in params) {
				if (p[0] != '<') {
					// regular piece of route
					route.append (Regex.escape_string (p));
				} else {
					// extract parameter
					var cap  = p.slice (1, p.length - 1).split (":", 2);
					var type = cap.length == 1 ? "string" : cap[0];
					var key  = cap.length == 1 ? cap[0] : cap[1];

					captures.add (key);
					route.append ("(?<%s>%s)".printf (key, this.router.types[type]));
				}
			}

			route.append ("$");

			var regex = new Regex (route.str, RegexCompileFlags.OPTIMIZE);

			// register a matcher based on the generated regular expression
			this.matcher = (req) => {
				MatchInfo match_info;
				if (regex.match (req.path, 0, out match_info)) {
					// populate the request parameters
					foreach (var capture in captures) {
						req.params[capture] = match_info.fetch_named (capture);
					}
					return true;
				}
				return false;
			};

			message ("registered %s", route.str);
		}

		/**
		 * Matches the given request and populate its parameters on success.
         *
		 * @param req request that is being matched
		 */
		public bool match (Request req) {
			return this.matcher (req);
		}

		/**
		 * Fire a request-response couple.
		 *
		 * This will apply the callback on the request and response.
         *
		 * @param req
		 * @param res
		 */
		public void fire (Request req, Response res) {
			this.callback (req, res);
		}
	}
}
