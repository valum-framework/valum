using VSGI;

namespace Valum {

	/**
	 * Route that matches Request path.
	 *
	 * @since 0.0.1
	 */
	public class Route : Object {

		/**
		 * Router that declared this route.
         *
		 * This is used to hold parameters types.
		 */
		private weak Router router;

		/**
		 * Match the request and populate the {@link Request.params}.
		 *
		 * @since 0.1
		 *
		 * @param req request being matched
		 */
		public delegate bool Matcher (Request req);

		/**
		 * Handle a pair of request and response.
		 *
		 * @since 0.0.1
		 *
		 * @throws Redirection perform a 3xx HTTP redirection
		 * @throws ClientError trigger a 4xx client error
		 * @throws ServerError trigger a 5xx server error
		 *
		 * @param req request being handled
		 * @param res response to send back to the requester
		 */
		public delegate void Handler (Request req, Response res) throws Redirection, ClientError, ServerError;

		/**
		 * Create a Route using a custom matcher.
		 *
		 * This is the lowest-level mean to create a Route instance.
		 *
		 * The matcher should take in consideration the {@link Router.scopes}
		 * stack if it has to deal with the {@link Request.uri}.
		 *
		 * @since 0.1
		 */
		public Route (Router router, Matcher matcher, Handler callback) {
			this.router = router;
			this.match  = matcher;
			this.fire   = callback;
		}

		/**
		 * Create a Route for a given callback using a {@link Regex}.
		 *
		 * The providen regular expression pattern will be extracted, scoped, anchored
		 * and optimized. This means you must not anchor the regex yourself with '^'
		 * and '$' characters and providing a pre-optimized Regex is useless.
		 *
		 * Like for {@link Route.from_rule}, the regular expression starts matching
		 * after the scopes and the leading '/' character.
		 *
		 * @since 0.1
		 */
		public Route.from_regex (Router router, Regex regex, Handler callback) throws RegexError {
			this.router = router;
			this.fire   = callback;

			var pattern = new StringBuilder ("^");

			// scope the route
			foreach (var scope in router.scopes.head) {
				pattern.append (Regex.escape_string ("/%s".printf (scope)));
			}

			// root the route
			pattern.append ("/");

			pattern.append (regex.get_pattern ());

			pattern.append ("$");

			// regex are optimized automatically :)
			regex = new Regex (pattern.str, RegexCompileFlags.OPTIMIZE);

			var captures      = new SList<string> ();
			var capture_regex = new Regex ("\\(\\?<(\\w+)>.+\\)");
			MatchInfo capture_match_info;

			// extract the captures from the regular expression
			if (capture_regex.match (regex.get_pattern (), 0, out capture_match_info)) {
				foreach (var capture in capture_match_info.fetch_all ()) {
					captures.append (capture);
				}
			}

			this.match = (req) => {
				MatchInfo match_info;
				if (regex.match (req.uri.get_path (), 0, out match_info)) {
					if (captures.length () > 0) {
						// populate the request parameters
						var p = new HashTable<string, string?> (str_hash, str_equal);
						foreach (var capture in captures) {
							p[capture] = match_info.fetch_named (capture);
						}
						req.params = p;
					}
					return true;
				}
				return false;
			};
		}

		/**
		 * Create a Route for a given callback from a rule.
         *
		 * Rule are scoped from the {@link Router.scope} fragment stack and compiled
		 * down to {@link GLib.Regex}.
		 *
		 * @since 0.0.1
		 */
		public Route.from_rule (Router router, string rule, Handler callback) throws RegexError {
			this.router   = router;
			this.fire     = callback;

			var param_regex = new Regex ("(<(?:\\w+:)?\\w+>)");
			var params      = param_regex.split_full (rule);
			var captures    = new SList<string> ();
			var route       = new StringBuilder ("^");

			// scope the route
			foreach (var scope in router.scopes.head) {
				route.append (Regex.escape_string ("/%s".printf (scope)));
			}

			// root the route
			route.append ("/");

			foreach (var p in params) {
				if (p[0] != '<') {
					// regular piece of route
					route.append (Regex.escape_string (p));
				} else {
					// extract parameter
					var cap  = p.slice (1, p.length - 1).split (":", 2);
					var type = cap.length == 1 ? "string" : cap[0];
					var key  = cap.length == 1 ? cap[0] : cap[1];

					if (!this.router.types.contains (type))
						error ("using an undefined type %s".printf (type));

					captures.append (key);

					route.append ("(?<%s>%s)".printf (key, this.router.types[type].get_pattern ()));
				}
			}

			route.append ("$");

			var regex = new Regex (route.str, RegexCompileFlags.OPTIMIZE);

			// register a matcher based on the generated regular expression
			this.match = (req) => {
				MatchInfo match_info;
				if (regex.match (req.uri.get_path (), 0, out match_info)) {
					if (captures.length () > 0) {
						// populate the request parameters
						var p = new HashTable<string, string?> (str_hash, str_equal);
						foreach (var capture in captures) {
							p[capture] = match_info.fetch_named (capture);
						}
						req.params = p;
					}
					return true;
				}
				return false;
			};
		}

		/**
		 * Matches the given request and populate its parameters on success.
         *
		 * @since 0.0.1
		 *
		 * @param req request that is being matched
		 */
		public Matcher match;

		/**
		 * Fire a request-response couple.
		 *
		 * This will apply the callback on the request and response.
         *
		 * @since 0.0.1
		 *
		 * @param req
		 * @param res
		 */
		public unowned Handler fire;
	}
}
