using Gee;

namespace Valum {
	public class Request : Object {
		public HashMap<string, string> params = new HashMap<string, string> ();
		public Soup.Message message { construct; get; }
		public string path {
			get { return this.message.uri.get_path(); }
		}
		public Soup.MessageHeaders headers {
			get { return this.message.request_headers; }
		}
		public Soup.MessageBody body {
			get { return this.message.request_body; }
		}
		public Request(Soup.Message msg) {
			Object(message: msg);
		}
	}
}
