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
	 * @since 0.3
	 */
	public enum RuleTokenType {
		OPENING_PARENTHESIS,
		CLOSING_PARENTHESIS,
		OPTIONAL,
		WILDCARD,
		PARAMETER,
		PIECE
	}

	/**
	 * @since 0.3
	 */
	public struct RuleToken {
		RuleTokenType type;
		string        segment;
	}

	/**
	 *
	 */
	public struct RuleParameter {
		string? type;
		string  name;
	}

	/**
	 * Tokenize a rule into a sequence of {@link Valum.RuleToken}.
	 *
	 * @since 0.3
	 */
	public RuleToken[] tokenize_rule (string rule) throws RegexError {
		var parts = /([\*\?\(\)]|<(?:\w+:)?\w+>)/.split_full (rule);
		var segments = new RuleToken[parts.length];
		for (int i = 0; i < parts.length; i++) {
			RuleTokenType type;
			switch (parts[i][0]) {
				case '*':
					type = RuleTokenType.WILDCARD;
					break;
				case '?':
					type = RuleTokenType.OPTIONAL;
					break;
				case '(':
					type = RuleTokenType.OPENING_PARENTHESIS;
					break;
				case ')':
					type = RuleTokenType.CLOSING_PARENTHESIS;
					break;
				case '<':
					type = RuleTokenType.PARAMETER;
					break;
				default:
					type = RuleTokenType.PIECE;
					break;
			}
			segments[i] = {type, parts[i]};
		}
		return segments;
	}

	/**
	 * Parse a string containing a {@link Valum.RuleTokenType.PARAMETER}.
	 *
	 * @since 0.3
	 */
	public RuleParameter parse_parameter (string parameter) {
		var cap = parameter.slice (1, parameter.length - 1).split (":", 2);
		return {cap.length == 1 ? null : cap[0], cap.length == 1 ? cap[0] : cap[1]};
	}

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
		 * Create a Route for a given callback from a rule.
		 *
		 * @since 0.0.1
		 *
		 * @param rule  compiled down ot a regular expression and captures all
		 *              paths if set to 'null'
		 * @param types type mapping to figure out types in rule or 'null' to
		 *              prevent any form of typing
		 */
		public RuleRoute (Method                    method,
		                  string                    rule,
		                  HashTable<string, Regex>? types,
		                  owned HandlerCallback     handler) throws RegexError {
			var pattern = new StringBuilder ();

			pattern.append_c ('^');

			foreach (var p in tokenize_rule (rule)) {
				switch (p.type) {
					case RuleTokenType.WILDCARD:
						pattern.append (".*");
						break;
					case RuleTokenType.OPTIONAL:
					case RuleTokenType.OPENING_PARENTHESIS:
						pattern.append ("(?:");
						break;
					case RuleTokenType.CLOSING_PARENTHESIS:
						pattern.append (p.segment);
						break;
					case RuleTokenType.PARAMETER:
						var parameter = parse_parameter (p.segment);

						if (types == null) {
							pattern.append_printf ("(?<%s>\\w+)", parameter.name);
						} else if (!types.contains (parameter.type ?? "string")) {
							throw new RegexError.COMPILE ("using an undefined type '%s'", parameter.type ?? "string");
						} else {
							pattern.append_printf ("(?<%s>%s)", parameter.name, types[parameter.type ?? "string"].get_pattern ());
						}
						break;
					default:
						// regular piece of route
						pattern.append (Regex.escape_string (p.segment));
						break;
				}
			}

			pattern.append_c ('$');

			Object (method: method, rule: rule, regex: new Regex (pattern.str, RegexCompileFlags.OPTIMIZE));
			set_handler_callback ((owned) handler);
		}
	}
}
