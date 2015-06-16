using Soup;

namespace VSGI {
	/**
	 * Response representing a request resource.
	 *
	 * @since 0.0.1
	 */
	public abstract class Response : OutputStream {

		/**
		 * Request to which this response is responding.
		 *
		 * @since 0.1
		 */
		public Request request { construct; get; }

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
		public abstract MessageHeaders headers { get; }
	}
}
