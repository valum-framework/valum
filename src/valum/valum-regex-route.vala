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
	 * Route based on {@link GLib.Regex}.
	 *
	 * The providen regular expression pattern will be extracted, scoped,
	 * anchored and optimized. This means you must not anchor the regex yourself
	 * with '^' and '$' characters and providing a pre-optimized {@link  GLib.Regex}
	 * is useless.
	 *
	 * Like for the rules, the regular expression starts matching after the
	 * scopes and the leading '/' character.
	 *
	 * @since 0.3
	 */
	public class RegexRoute : Route {

		/**
		 * @since 0.3
		 */
		public Regex regex { construct; get; }

		private SList<string> captures = new SList<string> ();


		/**
		 *
		 * @since 0.1
		 */
		public RegexRoute (Method method, Regex regex, owned HandlerCallback handler) throws RegexError {
			Object (method: method, regex: regex);

			// extract the captures from the regular expression
			MatchInfo capture_match_info;
			if (/\(\?<(\w+)>.+?\)/.match (regex.get_pattern (), 0, out capture_match_info)) {
				do {
					captures.append (capture_match_info.fetch (1));
				} while (capture_match_info.next ());
			}

			fire = (owned) handler;
		}

		public override bool match (Request req, Context context) {
			MatchInfo match_info;
			if (_regex.match (req.uri.get_path (), 0, out match_info)) {
				if (captures.length () > 0) {
					// populate the context parameters
					foreach (var capture in captures) {
						context[capture] = match_info.fetch_named (capture);
					}
				}
				return true;
			}
			return false;
		}
	}
}
