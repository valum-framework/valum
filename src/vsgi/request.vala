namespace VSGI {

	/**
	 * Request
	 */
	public abstract class Request : InputStream {

		// HTTP/1.1 http://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html
		public const string OPTIONS = "OPTIONS";
		public const string GET     = "GET";
		public const string HEAD    = "HEAD";
		public const string POST    = "POST";
		public const string PUT     = "PUT";
		public const string DELETE  = "DELETE";
		public const string TRACE   = "TRACE";
		public const string CONNECT = "CONNECT";

		public const string PATCH   = "PATCH";

		/**
		 * List of all supported HTTP methods.
		 */
		public const string[] METHODS = {OPTIONS, GET, HEAD, POST, PUT, DELETE, TRACE, CONNECT, PATCH};

		/**
		 * Parameters for the request.
		 *
		 * These should be extracted from the URI path.
		 */
		public HashTable<string, string>? params = null;

		/**
		 * Request HTTP method
		 *
		 * Should be one of OPTIONS, GET, HEAD, POST, PUT, DELETE, TRACE, CONNECT
		 * or PATCH.
		 *
		 * Constants for every standard HTTP methods are providen as constants in
		 * this class.
		 */
		public abstract string method { owned get; }

		/**
		 * Request URI
         *
		 * The implementation is based on libsoup.
         *
		 * The URI, protocol and HTTP query and other request information is
		 * made available through this property.
		 */
		public abstract Soup.URI uri { get; }

		/**
		 * Request headers.
		 */
		public abstract Soup.MessageHeaders headers { get; }

		/**
		 * Request cookies.
         *
		 * Cookies will be computed from the Cookie HTTP header everytime they are
		 * accessed.
		 */
		public SList<Soup.Cookie> cookies {
			owned get {
				var cookies = new SList<Soup.Cookie> ();

				foreach (var cookie in this.headers.get_list ("Cookie").split (",")) {
					cookies.append (Soup.Cookie.parse (cookie, this.uri));
				}

				return cookies;
			}
		}
	}
}
