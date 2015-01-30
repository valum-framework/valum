namespace VSGI {

	/**
	 * Response
	 *
	 * @since 0.0.1
	 */
	public abstract class Response : OutputStream {

		/**
		 * Response status.
		 *
		 * @since 0.0.1
		 */
		public abstract uint status { get; set; }

		/**
		 * Response headers.
		 *
		 * @since 0.0.1
		 */
		public abstract Soup.MessageHeaders headers { get; }

		/**
		 * Property for the Set-Cookie header.
		 * Set cookies for this Response.
		 *
		 * @since 0.1
		 */
		public SList<Soup.Cookie> cookies {
			owned get {
				var cookies = new SList<Soup.Cookie> ();

				foreach (var cookie in this.headers.get_list ("Set-Cookie").split (",")) {
					cookies.append (Soup.Cookie.parse (cookie, new Soup.URI (null)));
				}

				return cookies;
			}
			set {
				foreach (var cookie in value) {
					this.headers.replace ("Set-Cookie", cookie.to_set_cookie_header ());
				}
			}
		}
	}
}
