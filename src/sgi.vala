using Gee;

namespace SGI {
	public abstract class Application {

		// Environment of the Application that can be setted from the request_handler
		public Map<string, string> environment { get; set; }
	}

	public abstract class Request : Object {

		public Map<string, string> params { get; set; }

		public Map<string, string> query { construct; get; }

		public string path { construct; get; }

		public string method { construct; get; }

		public MultiMap<string, string> headers { construct; get; }

		public DataInputStream body { construct; get; }
	}

	public abstract class Response : Object {

		public abstract string mime { get; set; }

		public abstract uint status { get; set; }

		public MultiMap<string, string> headers { construct; get; }

		public DataOutputStream body { construct; get; }
	}
}
