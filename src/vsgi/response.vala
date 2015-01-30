namespace VSGI {

	/**
	 * Response
	 *
	 * @since 0.0.1
	 */
	public abstract class Response : OutputStream {

		/**
		 * Request from which this response originates.
		 *
		 * Protected since the Request is assumed accessible in the public scope
		 * through the application. This is a facility for accessing request from
		 * the implementation.
		 *
		 * @since 0.1
		 */
		protected Request request;

		/**
		 * Response HTTP status.
		 *
		 * @since 0.0.1
		 */
		public abstract uint status { get; set; }

		/**
		 * Response HTTP headers.
		 *
		 * @since 0.0.1
		 */
		public abstract Soup.MessageHeaders headers { get; }

		/**
		 * Create a new Response instance.
		 *
		 * @since 0.1
		 *
		 * @param request from which this response originates.
		 */
		public Response (Request request) {
			this.request = request;
		}

		/**
		 * Cookies to send back to the client.
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
