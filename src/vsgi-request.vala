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
using Soup;

namespace VSGI {
	/**
	 * Request representing a request of a resource.
	 *
	 * @since 0.0.1
	 */
	public abstract class Request : Object {

		/**
		 * HTTP/1.1 standard methods.
		 *
		 * [[http://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html]]
		 *
		 * @since 0.1
		 */
		[Deprecated (since = "0.3", replacement = "Soup.Method.OPTIONS")]
		public const string OPTIONS = "OPTIONS";
		[Deprecated (since = "0.3", replacement = "Soup.Method.GET")]
		public const string GET     = "GET";
		[Deprecated (since = "0.3", replacement = "Soup.Method.HEAD")]
		public const string HEAD    = "HEAD";
		[Deprecated (since = "0.3", replacement = "Soup.Method.POST")]
		public const string POST    = "POST";
		[Deprecated (since = "0.3", replacement = "Soup.Method.PUT")]
		public const string PUT     = "PUT";
		[Deprecated (since = "0.3", replacement = "Soup.Method.DELETE")]
		public const string DELETE  = "DELETE";
		[Deprecated (since = "0.3", replacement = "Soup.Method.TRACE")]
		public const string TRACE   = "TRACE";
		[Deprecated (since = "0.3", replacement = "Soup.Method.CONNECT")]
		public const string CONNECT = "CONNECT";

		/**
		 * PATCH method defined in RFC5789.
		 *
		 * [[http://tools.ietf.org/html/rfc5789]]
		 *
		 * This is a proposed standard, it is not part of the current HTTP/1.1
		 * protocol.
		 *
		 * @since 0.1
		 */
		[Deprecated (since = "0.3", replacement = "Soup.Method.PROPPATCH")]
		public const string PATCH = "PATCH";

		/**
		 * List of all supported HTTP methods.
		 *
		 * @since 0.1
		 */
		[Deprecated (since = "0.3")]
		public const string[] METHODS = {OPTIONS, GET, HEAD, POST, PUT, DELETE, TRACE, CONNECT, PATCH};

		/**
		 * Parameters for the request.
		 *
		 * These should be extracted from the URI path.
		 *
		 * @since 0.0.1
		 */
		[Deprecated (since = "0.2")]
		public HashTable<string, string?>? @params { get; set; default = null; }

		/**
		 * Connection containing raw streams.
		 *
		 * @since 0.2
		 */
		public IOStream connection { construct; get; }

		/**
		 * Request HTTP version.
		 */
		public abstract HTTPVersion http_version { get; }

		/**
		 * Request HTTP method
		 *
		 * Should be one of OPTIONS, GET, HEAD, POST, PUT, DELETE, TRACE, CONNECT
		 * or PATCH.
		 *
		 * Constants for every standard HTTP methods are providen as constants in
		 * this class.
		 *
		 * @since 0.0.1
		 */
		public abstract string method { owned get; }

		/**
		 * Request URI.
         *
		 * The URI, protocol and HTTP query and other request information is
		 * made available through this property.
		 *
		 * @since 0.1
		 */
		public abstract URI uri { get; }

		/**
		 * HTTP query.
		 *
		 * This is null if the query hasn't been set.
		 *
		 * /path/? empty query
		 * /path/  null query
		 *
		 * @since 0.1
		 */
		public abstract HashTable<string, string>? query { get; }

		/**
		 * Request headers.
		 *
		 * @since 0.0.1
		 */
		public abstract MessageHeaders headers { get; }

		/**
		 * Request body.
		 *
		 * The provided stream is filtered by the implementation according to
		 * the 'Transfer-Encoding' header value.
		 *
		 * The default implementation returns the connection stream unmodified.
		 *
		 * @since 0.2
		 */
		public virtual InputStream body {
			get {
				return this.connection.input_stream;
			}
		}
	}
}
