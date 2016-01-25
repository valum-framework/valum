/*
 * This file is part of Valum.
 *
 * Valum is free software: you can redistribute it and/or modify it under the
 * terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) any
 * later version.
 *
 * Valum is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with Valum.  If not, see <http://www.gnu.org/licenses/>.
 */

using GLib;
using VSGI;

namespace Valum {

	/**
	 * Route provides a {@link Valum.MatcherCallback} and {@link Valum.HandlerCallback} to
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
		 * HTTP method this is matching or 'null' if it does apply.
		 *
		 * @since 0.2
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
		public Route (Router router, string? method, owned MatcherCallback matcher, owned HandlerCallback callback) {
			Object (router: router, method: method);
			this.match = (owned) matcher;
			this.fire  = (owned) callback;
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
		public Route.from_regex (Router router, string? method, Regex regex, owned HandlerCallback callback) throws RegexError {
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
			var captures = new SList<string> ();
			MatchInfo capture_match_info;

			if (/\(\?<(\w+)>.+?\)/.match (pattern.str, 0, out capture_match_info)) {
				do {
					captures.append (capture_match_info.fetch (1));
				} while (capture_match_info.next ());
			}

			// regex are optimized automatically :)
			var prepared_regex = new Regex (pattern.str, RegexCompileFlags.OPTIMIZE);

			this (router, method, (req, context) => {
				MatchInfo match_info;
				if (prepared_regex.match (req.uri.get_path (), 0, out match_info)) {
					if (captures.length () > 0) {
						// populate the context parameters
						foreach (var capture in captures) {
							context[capture] = match_info.fetch_named (capture);
						}
					}
					return true;
				}
				return false;
			}, (owned) callback);
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
		public Route.from_rule (Router router, string? method, string? rule, owned HandlerCallback callback) throws RegexError {
			var params = /(<(?:\w+:)?\w+>)/.split_full (rule == null ? "" : rule);
			var pattern = new StringBuilder ();

			// catch-all null rule
			if (rule == null) {
				pattern.append ("(?<path>.*)");
			}

			foreach (var p in @params) {
				if (p[0] != '<') {
					// regular piece of route
					pattern.append (Regex.escape_string (p));
				} else {
					// extract parameter
					var cap  = p.slice (1, p.length - 1).split (":", 2);
					var type = cap.length == 1 ? "string" : cap[0];
					var key  = cap.length == 1 ? cap[0] : cap[1];

					if (!router.types.contains (type))
						throw new RegexError.COMPILE ("using an undefined type %s", type);

					pattern.append ("(?<%s>%s)".printf (key, router.types[type].get_pattern ()));
				}
			}

			this.from_regex (router, method, new Regex (pattern.str), (owned) callback);
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
		 *
		 * @since 0.2
		 */
		public Route then (owned HandlerCallback handler) {
			return this.router.matcher (this.method, (req, context) => {
				// since the same matcher is shared, we preserve the context intact
				return match (req, new Context.with_parent (context));
			}, (owned) handler);
		}
	}
}
