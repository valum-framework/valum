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
	public abstract class Route : Object {

		private HandlerCallback _fire;

		/**
		 * HTTP method this is matching or 'null' if it does apply.
		 *
		 * @since 0.2
		 */
		public Method method { construct; get; }

		/**
		 * Matches the given request and populate its parameters on success.
         *
		 * @since 0.0.1
		 */
		public abstract bool match (Request req, Context ctx);

		/**
		 * Apply the handler on the request and response.
         *
		 * @since 0.0.1
		 */
		public bool fire (Request req, Response res, NextCallback next, Context ctx) throws Success,
		                                                                                    Redirection,
		                                                                                    ClientError,
		                                                                                    ServerError,
																							Error {
			return _fire (req, res, next, ctx);
		}

		/**
		 * @since 0.3
		 */
		public void set_handler_callback (owned HandlerCallback fire) {
			_fire = (owned) fire;
		}

		/**
		 * Pushes the handler in the {@link Router} queue to produce a sequence
		 * of callbacks that reuses the same matcher.
		 *
		 * @since 0.2
		 */
		public Route then (owned HandlerCallback handler) {
			var old_fire = (owned) _fire;
			_fire = (req, res, next, context) => {
				return old_fire (req, res, (req, res) => {
					// since the same matcher is shared, we preserve the context intact
					return handler (req, res, next, context);
				}, context);
			};
			return this;
		}
	}
}
