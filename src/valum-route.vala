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
	 * Various flags for {@link Valum.Route} used mainly for semantical and
	 * optimization purposes.
	 *
	 * @since 0.3
	 */
	public enum RouteFlags {
		NONE = 0,
		OPTIONS,
		GET,
		HEAD,
		POST,
		PUT,
		DELETE,
		TRACE,
		CONNECT,
		/**
		 * All HTTP methods.
		 */
		ALL = OPTIONS | GET | HEAD | POST | PUT | DELETE | TRACE | CONNECT;

		/**
		 * Obtain flags for a given {@link VSGI.Request}.
		 */
		public static RouteFlags from_request (Request req) {
			return from_method (req.method);
		}

		/**
		 *
		 */
		public static RouteFlags from_method (string method) {
			switch (method) {
				case "OPTIONS":
					return RouteFlags.OPTIONS;
				case "GET":
					return RouteFlags.GET;
				case "HEAD":
					return RouteFlags.HEAD;
				case "POST":
					return RouteFlags.POST;
				case "PUT":
					return RouteFlags.PUT;
				case "DELETE":
					return RouteFlags.DELETE;
				case "TRACE":
					return RouteFlags.TRACE;
				case "CONNECT":
					return RouteFlags.CONNECT;
				default:
					return RouteFlags.NONE;
			};
		}

		/**
		 * Build the value of an 'Allowed' HTTP header.
		 */
		public string to_allowed_header () {
			return to_string ()[13:-1];
		}

	}

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
	public struct Route {

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
		 *
		 * @since 0.3
		 */
		public RouteFlags flags;
	}
}
