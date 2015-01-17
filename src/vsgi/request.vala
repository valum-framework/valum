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

		/**
		 * Request environment.
         *
		 * This is providen by the server implementation.
		 */
		public abstract Map<string, string> environment { get; }

		/**
		 * Request method
		 */
		public abstract string method { get; }

		/**
		 * Parameters for the request.
		 *
		 * These should be extracted from the URI path.
		 */
		public Map<string, string> params { get; set; default = new HashMap<string, string> (); }

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
		public abstract MultiMap<string, string> headers { get; }

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
				foreach (var cookie in this.headers["Cookie"]) {
					cookies.add(Soup.Cookie.parse (cookie, this.uri));
				}
				return cookies;
			}
		}
	}
}