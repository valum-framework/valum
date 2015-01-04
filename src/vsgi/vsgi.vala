using Gee;

namespace VSGI {

	/**
	 * Application that handles Request and produce Response.
     *
	 * Provides basic implementation for libsoup and FastCGI handlers.
	 */
	public abstract class Application {

		// Environment of the Application that can be setted from the request_handler
		public Map<string, string> environment { get; set; default = new HashMap<string, string> (); }
	}

	/**
	 * Request
	 */
	public abstract class Request : InputStream {

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
