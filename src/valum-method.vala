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
	 */
	[Flags]
	[Version (since = "0.3")]
	public enum Method {
		[Version (since = "0.3")]
		OPTIONS,
		[Version (since = "0.3")]
		ONLY_GET,
		[Version (since = "0.3")]
		HEAD,
		[Version (since = "0.3")]
		GET = ONLY_GET | HEAD,
		[Version (since = "0.3")]
		PUT,
		[Version (since = "0.3")]
		POST,
		[Version (since = "0.3")]
		DELETE,
		[Version (since = "0.3")]
		TRACE,
		[Version (since = "0.3")]
		CONNECT,
		[Version (since = "0.3")]
		PATCH,

		/**
		 * HTTP methods considered safe according to RFC 7231.
		 */
		[Version (since = "0.3")]
		SAFE = OPTIONS | HEAD | ONLY_GET | TRACE,

		/**
		 * HTTP methods considered idempotent according to RFC 7231.
		 */
		[Version (since = "0.3")]
		ITEMPOTENT = SAFE | PUT | DELETE,

		/**
		 * HTTP methods considered cacheable according to RFC 7231.
		 *
		 * POST is considered cacheable because it completely replaces the
		 * resources. The second call does not change the state of the resource.
		 */
		[Version (since = "0.3")]
		CACHEABLE = GET | HEAD | POST,

		/**
		 * Mask for all standard HTTP methods.
		 */
		[Version (since = "0.3")]
		ALL = OPTIONS | GET | HEAD | PUT | POST | DELETE | TRACE | CONNECT | PATCH,

		/**
		 * If this is used, the {@link Valum.Route} object must perform its own
		 * method matching.
		 */
		[Version (since = "0.3")]
		OTHER,

		/**
		 * Mask for all methods, including non-standard ones.
		 */
		[Version (since = "0.3")]
		ANY = ALL | OTHER,

		/**
		 * Indicate that the method literally provided by the {@link Valum.Route}
		 * object which declared it.
		 *
		 * This has an impact on introspected routes to build the 'Allow'
		 * header.
		 */
		[Version (since = "0.3", experimental = true)]
		PROVIDED,

		/**
		 * Mask for all meta flags.
		 */
		[Version (since = "0.3", experimental = true)]
		META = PROVIDED;

		[Version (since = "0.3")]
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
