using Gee;

namespace SGI {
	public abstract class Application {

		// Environment of the Application that can be setted from the request_handler
		public Map<string, string> environment { get; set; default = new HashMap<string, string> (); }

		// Handles a Request and produce a Response
		public abstract void request_handler (Request req, Response res);

		// libsoup based handler
		public void soup_request_handler (Soup.Server server,
				Soup.Message msg,
				string path,
				GLib.HashTable<string, string>? query,
				Soup.ClientContext client) {

			var qry = new HashMap<string, string> ();

			if (query != null) {
				query.foreach((key, value) => {
					qry[key] = value;
				});
			}

			var req = new SoupRequest(msg, qry);
			var res = new SoupResponse(msg);

			this.request_handler (req, res);
		}

		// FastCGI handler
		//public void fastcgi_request_handler (FastCGI.request request) {
		// TODO: implementation

		//var req = new FastCGIRequest(request);
		//var res = new FastCGIResponse ();

		//this.request_handler (req, res);
		//}
	}

	public abstract class Request : Object {

		public Map<string, string> params { get; set; default = new HashMap<string, string> (); }

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
