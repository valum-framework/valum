using Gee;

/**
 * VSGI is an set of abstraction and implementations used to build generic web
 * application in Vala.
 *
 * It is minimalist and relies on libsoup, a good and stable HTTP library.
 *
 * Two implementation are planned: Soup.Server and FastCGI. The latter
 * integrates with pretty much any web server.
 */
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
		 * Parameters for the request.
		 *
		 * These should be extracted from the URI path.
		 */
		public Map<string, string> params = new HashMap<string, string> ();

		/**
		 * Request method
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
		 * Cookie implementation is based on libsoup.
         *
		 * This property is a wrapper around the Cookie request header.
		 */
		public Gee.List<Soup.Cookie> cookies {
			owned get {
				var cookies = new ArrayList<Soup.Cookie> ();

				foreach (var cookie in this.headers.get_list("Set-Cookie").split(",")) {
					cookies.add (Soup.Cookie.parse (cookie, null));
				}

				return cookies;
			}
		}
	}
}
