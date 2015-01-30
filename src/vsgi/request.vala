namespace VSGI {

	/**
	 * Request
	 *
	 * @since 0.0.1
	 */
	public abstract class Request : InputStream {

		/**
		 * HTTP/1.1 standard methods.
		 *
		 * @link  http://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html
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
		 * This is a proposed standard, it is not part of the current HTTP/1.1
		 * protocol.
		 *
		 * @link  http://tools.ietf.org/html/rfc5789
		 * @since 0.1
		 */
		public const string PATCH   = "PATCH";

		/**
		 * List of all supported HTTP methods.
		 *
		 * @since 0.1
		 */
		public const string[] METHODS = {OPTIONS, GET, HEAD, POST, PUT, DELETE, TRACE, CONNECT, PATCH};

		/**
		 * Parameters for the request.
		 *
		 * @since 0.0.1
		 *
		 * These should be extracted from the URI path.
		 */
		public HashTable<string, string?>? @params = null;

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
		 * Request URI
         *
		 * The implementation is based on libsoup.
         *
		 * The URI, protocol and HTTP query and other request information is
		 * made available through this property.
		 *
		 * @since 0.1
		 */
		public abstract Soup.URI uri { get; }

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
		public abstract Soup.MessageHeaders headers { get; }

		/**
		 * User session.
		 *
		 * As session implementation might differ from a server to another, you have
		 * to submit back the session to apply your changes.
		 *
		 * Assigning null to sessions will delete the session.
		 *
		 * @return filled table with session data
		 */
		public abstract HashTable<string, string>? session { owned get; set; }

		/**
		 * Request cookies.
         *
		 * Cookies will be computed from the Cookie HTTP header everytime they are
		 * accessed.
		 *
		 * @since 0.1
		 */
		public SList<Soup.Cookie> cookies {
			owned get {
				var cookies = new SList<Soup.Cookie> ();

				foreach (var cookie in this.headers.get_list ("Cookie").split ("; ")) {
					cookies.prepend (Soup.Cookie.parse (cookie, this.uri));
				}

				cookies.reverse ();

				return cookies;
			}
		}
	}
}
