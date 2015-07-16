using GLib;
using VSGI;

namespace Valum {

	/**
	 * Route provides a {@link Route.MatcherCallback} and {@link Route.HandlerCallback} to
	 * respectively match and handle a {@link VSGI.Request} and
	 * {@link VSGI.Response}.
	 *
	 * Route can be declared using the rule system, a regular expression or an
	 * arbitrary request-matching callback.
	 *
	 * @since 0.0.1
	 */
	public class Route : Object {

		/**
		 * Router that declared this route.
		 *
		 * This is used to hold parameters types and have an access to the
		 * scope stack.
		 *
		 * @since 0.1
		 */
		public weak Router router { construct; get; }

		/**
		 * @since 0.3
		 */
		public string? method { construct; get; }

		/**
		 * Create a Route using a custom matcher.
		 *
		 * This is the lowest-level mean to create a Route instance.
		 *
		 * The matcher should take in consideration the {@link Router.scopes}
		 * stack if it has to deal with the {@link VSGI.Request.uri}.
		 *
		 * @since 0.1
		 */
		public Route (Router router, string? method, MatcherCallback matcher, HandlerCallback callback) {
			Object (router: router, method: method);
			this.match  = matcher;
			this.fire   = callback;
		}

		/**
		 * Create a Route for a given callback using a {@link GLib.Regex}.
		 *
		 * The providen regular expression pattern will be extracted, scoped,
		 * anchored and optimized. This means you must not anchor the regex
		 * yourself with '^' and '$' characters and providing a pre-optimized
		 * {@link GLib.Regex} is useless.
		 *
		 * Like for the rules, the regular expression starts matching after the
		 * scopes and the leading '/' character.
		 *
		 * @since 0.1
		 */
		public Route.from_regex (Router router, string? method, Regex regex, HandlerCallback callback) throws RegexError {
			Object (router: router, method: method);
			this.fire = callback;

			var pattern = new StringBuilder ("^");

			// root the route
			pattern.append ("/");

			// scope the route
			foreach (var scope in router.scopes.head) {
				pattern.append (Regex.escape_string ("%s/".printf (scope)));
			}

			pattern.append (regex.get_pattern ());

			pattern.append ("$");

			// extract the captures from the regular expression
			var captures      = new SList<string> ();
			var capture_regex = new Regex ("\\(\\?<(\\w+)>.+\\)");
			MatchInfo capture_match_info;

			if (capture_regex.match (pattern.str, 0, out capture_match_info)) {
				foreach (var capture in capture_match_info.fetch_all ()) {
					captures.append (capture);
				}
			}

			// regex are optimized automatically :)
			var prepared_regex = new Regex (pattern.str, RegexCompileFlags.OPTIMIZE);

			this.match = (req) => {
				MatchInfo match_info;
				if (prepared_regex.match (req.uri.get_path (), 0, out match_info)) {
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
		 * Rule are scoped from the {@link Router.scope} fragment stack and
		 * compiled down to {@link GLib.Regex}.
		 *
		 * Rule start matching after the first '/' character of the request URI
		 * path.
		 *
		 * @since 0.0.1
		 *
		 * @param rule compiled down ot a regular expression and captures all
		 *             paths if set to null
		 */
		public Route.from_rule (Router router, string? method, string? rule, HandlerCallback callback) throws RegexError {
			Object (router: router, method: method);
			this.fire = callback;

			var param_regex = new Regex ("(<(?:\\w+:)?\\w+>)");
			var params      = param_regex.split_full (rule == null ? "" : rule);
			var captures    = new SList<string> ();
			var route       = new StringBuilder ("^");

			// root the route
			route.append ("/");

			// scope the route
			foreach (var scope in router.scopes.head) {
				route.append (Regex.escape_string ("%s/".printf (scope)));
			}

			// catch-all null rule
			if (rule == null) {
				captures.append ("path");
				route.append ("(?<path>.*)");
			}

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
		 */
		public MatcherCallback match;

		/**
		 * Apply the handler on the request and response.
         *
		 * @since 0.0.1
		 */
		public HandlerCallback fire;

		/**
		 * Pushes the handler in the {@link Router} queue to produce a sequence
		 * of callbacks that reuses the same matcher.
		 */
		public Route then (HandlerCallback handler) {
			return this.router.matcher (this.method, match, handler);
		}
	}
}
