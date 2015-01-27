namespace VSGI {

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
		public SList<Soup.Cookie> cookies {
			owned get {
				var cookies = new SList<Soup.Cookie> ();

				foreach (var cookie in this.headers.get_list ("Set-Cookie").split (",")) {
					cookies.append (Soup.Cookie.parse (cookie, null));
				}

				return cookies;
			}
			set {
				foreach (var cookie in value) {
					this.headers.replace ("Set-Cookie", cookie.to_set_cookie_header ());
				}
			}
		}

		/**
		 * Response headers.
		 */
		public abstract Soup.MessageHeaders headers { get; }
	}
}
