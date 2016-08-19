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

namespace Valum {

	/**
	 * Represent a set of HTTP methods.
	 *
	 * This is used for {@link Valum.Route} to define what methods are allowed
	 * for a given instance.
	 *
	 * @since 0.3
	 */
	[Flags]
	public enum Method {
		OPTIONS,
		ONLY_GET,
		HEAD,
		GET = ONLY_GET | HEAD,
		PUT,
		POST,
		DELETE,
		TRACE,
		CONNECT,
		PATCH,

		/**
		 * HTTP methods considered safe according to RFC 7231.
		 *
		 * @since 0.3
		 */
		SAFE = OPTIONS | HEAD | ONLY_GET | TRACE,

		/**
		 * HTTP methods considered idempotent according to RFC 7231.
		 *
		 * @since 0.3
		 */
		ITEMPOTENT = SAFE | PUT | DELETE,

		/**
		 * HTTP methods considered cacheable according to RFC 7231.
		 *
		 * POST is considered cacheable because it completely replaces the
		 * resources. The second call does not change the state of the resource.
		 *
		 * @since 0.3
		 */
		CACHEABLE = GET | HEAD | POST,

		/**
		 * Mask for all standard HTTP methods.
		 *
		 * @since 0.3
		 */
		ALL = OPTIONS | GET | HEAD | PUT | POST | DELETE | TRACE | CONNECT | PATCH,

		/**
		 * If this is used, the {@link Valum.Route} object must perform its own
		 * method matching.
		 *
		 * @since 0.3
		 */
		OTHER,

		/**
		 * Mask for all methods, including non-standard ones.
		 *
		 * @since 0.3
		 */
		ANY = ALL | OTHER,

		/**
		 * Indicate that the method literally provided by the {@link Valum.Route}
		 * object which declared it.
		 *
		 * This has an impact on introspected routes to build the 'Allow'
		 * header.
		 */
		PROVIDED,

		/**
		 * Mask for all meta flags.
		 */
		META = PROVIDED;

		/**
		 * @since 0.3
		 */
		public static Method from_string (string method) {
			switch (method) {
				case "OPTIONS":
					return OPTIONS;
				case "GET":
					return ONLY_GET;
				case "HEAD":
					return HEAD;
				case "PUT":
					return PUT;
				case "POST":
					return POST;
				case "DELETE":
					return DELETE;
				case "TRACE":
					return TRACE;
				case "CONNECT":
					return CONNECT;
				case "PATCH":
					return PATCH;
				default:
					return OTHER;
			}
		}
	}
}
