using Gee;

namespace Valum {
	public abstract class Request : Object {

		public HashMap<string, string> params { get; set; }

		public string path { construct; get; }

		public string method { construct; get; }

		public MultiMap<string, string> headers { construct; get; }

		public DataInputStream body { construct; get; }
	}
}
