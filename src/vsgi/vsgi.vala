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

		public Map<string, string> params { get; set; default = new HashMap<string, string> (); }

		public abstract Map<string, string> query { get; }

		public abstract string path { get; }

		public abstract string method { get; }

		public abstract MultiMap<string, string> headers { get; }
	}

	/**
	 * Response
	 */
	public abstract class Response : OutputStream {

		public abstract uint status { get; set; }

		/**
		 * Property for the Content-Type header.
		 */
		public abstract string mime { get; set; }

		public abstract MultiMap<string, string> headers { get; }
	}
}
