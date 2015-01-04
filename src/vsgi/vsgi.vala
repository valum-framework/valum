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
		 * Response headers.
		 */
		public abstract MultiMap<string, string> headers { get; }
	}
}
