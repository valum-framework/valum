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

using VSGI;

namespace Valum {

	/**
	 * Route based on a {@link Valum.MatcherCallback}.
	 */
	[Version (since = "0.3")]
	public class MatcherRoute : Route {

		[Version (since = "0.3")]
		public MatcherRoute (Method method, owned MatcherCallback matcher, Middleware middleware) {
			Object (method: method, middleware: middleware);
			set_matcher_callback ((owned) matcher);
		}

		private MatcherCallback _match = null;

		[Version (since = "0.3")]
		public void set_matcher_callback (owned MatcherCallback callback) {
			_match = (owned) callback;
		}

		public override bool match (Request req, Context ctx) {
			return unlikely (_match == null) ? false : _match (req, ctx);
		}

		public override string to_url_from_hash (HashTable<string, string>? @params = null) {
			error ("'MatcherRoute' does not support reversing URLs.");
		}
	}
}
