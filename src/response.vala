using Gee;

namespace Valum {
	public class Response : Object {

		public Soup.Message message { construct; get; }

		public string mime {
			get { return this.message.response_headers.get_content_type(null);}
			set { this.message.response_headers.set_content_type(value, null);}
		}

		public uint status {
			get { return this.message.status_code; }
			set { this.message.set_status(value); }
		}

        public Soup.MessageBody body {
            get { return this.message.response_body; }
        }

        public Soup.MessageHeaders headers {
            get { return this.message.response_headers; }
        }

		public Response(Soup.Message msg) {
            Object(message: msg);
			this.mime = "text/html";
			this.status = 200;
            this.headers.append("Server", Valum.APP_NAME);
		}

		public void append(string str) {
			this.message.response_body.append_take(str.data);
		}
	}
}
