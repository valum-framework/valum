using Gee;

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
		 */
		public abstract Soup.URI uri { get; }

		/**
		 * Request headers.
		 */
		public abstract MultiMap<string, string> headers { get; }

		/**
		 * Request Cookie.
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
