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
		 * These should be extracted from the uri path.
		 */
		public Map<string, string> params { get; set; default = new HashMap<string, string> (); }

		/**
		 * Request URI using libsoup implementation.
         *
		 * The uri, protocol and HTTP query and other request information is
		 * made available through this property.
		 */
		public abstract Soup.URI uri { get; }

		/**
		 * Request headers.
		 */
		public abstract MultiMap<string, string> headers { get; }

		/**
		 * Request Cookie.
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

	/**
	 * Response
	 */
	public abstract class Response : OutputStream {

		/**
		 * Response status.
		 */
		public abstract uint status { get; set; }

		/**
		 * Property for the Content-Type header.
		 */
		public abstract string mime { get; set; }

		/**
		 * Property for the Set-Cookie header.
		 * Set cookies for this Response.
		 */
		public Gee.List<Soup.Cookie> cookies {
			owned get {
				var cookies = new ArrayList<Soup.Cookie> ();
				foreach (var cookie in this.headers["Set-Cookie"]) {
					cookies.add(Soup.Cookie.parse (cookie, null));
				}
				return cookies;
			}
			set {
				foreach (var cookie in value) {
					this.headers["Set-Cookie"] = cookie.to_set_cookie_header ();
				}
			}
		}

		/**
		 * Response headers.
		 */
		public abstract MultiMap<string, string> headers { get; }
	}
}
