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
		public const string OPTIONS = "OPTIONS";
		public const string GET     = "GET";
		public const string HEAD    = "HEAD";
		public const string POST    = "POST";
		public const string PUT     = "PUT";
		public const string DELETE  = "DELETE";
		public const string TRACE   = "TRACE";
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
		public const string PATCH = "PATCH";

		/**
		 * List of all supported HTTP methods.
		 *
		 * @since 0.1
		 */
		public const string[] METHODS = {OPTIONS, GET, HEAD, POST, PUT, DELETE, TRACE, CONNECT, PATCH};

		/**
		 * Parameters for the request.
		 *
		 * These should be extracted from the URI path.
		 *
		 * @since 0.0.1
		 */
		public HashTable<string, string?>? @params { get; set; default = null; }

		/**
		 * Connection containing raw streams.
		 *
		 * @since 0.2
		 */
		public IOStream connection { construct; protected get; }

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
		 * Request cookies.
         *
		 * Cookies will be computed from the Cookie HTTP header everytime they are
		 * accessed.
		 *
		 * @since 0.1
		 */
		public SList<Cookie> cookies {
			owned get {
				var cookies = new SList<Cookie> ();
				var cookie_list = this.headers.get_list ("Cookie");

				if (cookie_list == null)
					return cookies;

				foreach (var cookie in cookie_list.split ("; ")) {
					cookies.prepend (Cookie.parse (cookie, this.uri));
				}

				cookies.reverse ();

				return cookies;
			}
		}

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
