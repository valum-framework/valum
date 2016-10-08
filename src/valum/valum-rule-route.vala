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
	 * Route based on the rule system.
	 *
	 * The rule pattern is composed of a few elements:
	 *
	 * - '<' '>' for parameters
	 * - '(' and ')' for group
	 * - '?' for optional
	 * - '*' for wildcard
	 *
	 * The content of a parameters is a name with an optional type such as
	 * '<type:name>'. Types are resolved in a provided mapping and names are
	 * pushed on the routing {@link Valum.Context}.
	 *
	 * A group allow a more fine-grained application for optional parts.
	 *
	 * The optional symbol makes the last character or group optional. If it
	 * contains parameters, they will not be pushed on the context.
	 *
	 * The wildcard stands for the '.*' regular expression, which match pretty
	 * much anything.
	 *
	 * @since 0.3
	 */
	public class RuleRoute : RegexRoute {

		/**
		 * @since 0.3
		 */
		public string rule { construct; get; }

		/**
		 * @since 0.3
		 */
		public HashTable<string, Regex> types { construct; get; }

		/**
		 * Create a Route for a given callback from a rule.
		 *
		 * @since 0.0.1
		 *
		 * @param rule  compiled down ot a regular expression and captures all
		 *              paths if set to 'null'
		 * @param types type mapping to figure out types in rule or 'null' to
		 *              prevent any form of typing
		 */
		public RuleRoute (Method                   method,
		                  string                   rule,
		                  HashTable<string, Regex> types,
		                  owned HandlerCallback    handler) throws RegexError {
			var pattern = new StringBuilder ();

			var @params = /([\*\?\(\)]|<(?:\w+:)?\w+>)/.split_full (rule);

			pattern.append_c ('^');

			foreach (var p in @params) {
				if (p == "*") {
					pattern.append (".*");
				} else if (p == "?" || p == ")") {
					pattern.append (p);
				} else if (p == "(") {
					pattern.append ("(?:");
				} else if (p[0] != '<') {
					// regular piece of route
					pattern.append (Regex.escape_string (p));
				} else {
					// extract parameter
					var cap  = p.slice (1, p.length - 1).split (":", 2);
					var type = cap.length == 1 ? "string" : cap[0];
					var key  = cap.length == 1 ? cap[0] : cap[1];

					if (types.contains (type)) {
						pattern.append_printf ("(?<%s>%s)", key, types[type].get_pattern ());
					} else if (type == "string") {
						pattern.append_printf ("(?<%s>\\w+)", key);
					} else {
						throw new RegexError.COMPILE ("using an undefined type '%s' for capture '%s'", type, key);
					}
				}
			}

			pattern.append_c ('$');

			Object (method: method, rule: rule, types: types, regex: new Regex (pattern.str, RegexCompileFlags.OPTIMIZE));
			_fire = (owned) handler;
		}

		private HandlerCallback _fire;

		public override bool fire (Request req, Response res, NextCallback next, Context ctx) throws Error {
			return _fire (req, res, next, ctx);
		}

		public override string to_url_from_hash (HashTable<string, string>? @params = null) {
			var url    = new StringBuilder ();
			var pieces = /([\*\?\(\)]|<(?:\w+:)?\w+>)/.split (rule);

			// TODO: check the group depth and immediate '?' after parameters
			var missing         = false;
			string? missing_key = null;

			foreach (var piece in pieces) {
				if (piece == "*" || piece == "(" || piece == ")") {
					continue;
				} else if (piece == "?") {
					missing = false;
				} else if (piece[0] != '<') {
					url.append (piece);
				} else {
					var cap  = piece.slice (1, piece.length - 1).split (":", 2);
					var key  = cap.length == 1 ? cap[0] : cap[1];
					if (@params != null && @params.contains (key)) {
						url.append (@params[key]);
					} else {
						missing     = true;
						missing_key = key;
					}
				}
			}

			if (missing) {
				error ("The parameter '%s' was not provided.", missing_key);
			}

			return url.str;
		}
	}
}
