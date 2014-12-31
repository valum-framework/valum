using Gee;

namespace SGI {
	public abstract class Application {

		// Environment of the Application that can be setted from the request_handler
		public Map<string, string> environment { get; set; }
	}

	public abstract class Request : Object {

		public Map<string, string> params { get; set; }

		public abstract Map<string, string> query { get; }

		public abstract string path { get; }

		public abstract string method { get; }

		public abstract MultiMap<string, string> headers { get; }

		public abstract InputStream body { get; }
	}

	public abstract class Response : Object {

		public abstract string mime { get; set; }

		public abstract uint status { get; set; }

		public abstract MultiMap<string, string> headers { get; }

		public abstract OutputStream body { get; }
	}
}
