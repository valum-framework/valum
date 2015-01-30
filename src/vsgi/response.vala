namespace VSGI {

	/**
	 * Response
	 *
	 * @since 0.0.1
	 */
	public abstract class Response : OutputStream {

		/**
		 * @since 0.1
		 */
		protected Request request;

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
		 * Create a new Response instance.
		 *
		 * @since 0.1
		 *
		 * @param request Request that originated this response
		 */
		public Response (Request request) {
			this.request = request;
		}

		/**
		 * Property for the Set-Cookie header.
		 *
		 * @since 0.1
		 */
		public SList<Soup.Cookie> cookies {
			set {
				this.headers.remove ("Set-Cookie");

				foreach (var cookie in value) {
					this.headers.append ("Set-Cookie", cookie.to_set_cookie_header ());
				}
			}
		}
	}
}
