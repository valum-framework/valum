using Gee;

namespace Valum {
	public class Request {
		public HashMap<string, string> params;
		public string path;
		private Soup.Message message;
        public Soup.MessageHeaders headers {
            get { return this.message.request_headers; }
        }
        public Soup.MessageBody body {
           get { return this.message.request_body; }
        }
		public Request(Soup.Message msg) {
			this.message = msg;
			this.path = msg.uri.get_path();
			this.params  = new HashMap<string, string>();
		}
	}
}
