using Gee;

namespace Valum {
	public class Request {
		public HashMap<string, string> params;
		public string path;
		private Soup.Message message;
		public Request(Soup.Message msg) {
			this.message = msg;
			this.path = msg.uri.get_path();
			this.params  = new HashMap<string, string>();
		}
	}
}
