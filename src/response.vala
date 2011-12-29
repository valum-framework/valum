using Gee;

namespace Valum {
	public class Response : Object {

		public HashMap<string, string> headers;
		public Gee.HashMap<string, Value?> vars;
		private Soup.Message message;

		public string mime {
			get { return this.message.response_headers.get_content_type(null);}
			set { this.message.response_headers.set_content_type(value, null);}
		}

		public uint status {
			get { return this.message.status_code; }
			set { this.message.set_status(value); }
		}

		public Response(Soup.Message msg) {
			this.message = msg;
			this.mime = "text/html";
			this.status = 200;
			this.headers = new HashMap<string, string>();
			this.message.response_headers.append("Server", Valum.APP_NAME);
			this.vars = new Gee.HashMap<string, Value?>();
		}

		public void append(string str) {
			this.message.response_body.append(Soup.MemoryUse.COPY, str.data);
		}

		// Sends request to client
		public void send() {
			foreach (var header in headers.entries) {
				this.message.response_headers.append(header.key, header.value);
			}
			this.message.response_body.complete();
		}
	}
}
