using FastCGI;
using Gee;

namespace VSGI {

	// FastCGI implmentation
	public class FastCGIRequest : Request {

		private weak FastCGI.request request;

		private string _method;
		private string _path;
		private Soup.URI _uri;
		private HashMap<string, string> _environment = new HashMap<string, string> ();
		private HashMultiMap<string, string> _headers = new HashMultiMap<string, string> ();

		public override Map<string, string> environment { get { return this._environment; } }

		public override Soup.URI uri { get { return this._uri; } }

		public override string method { get { return this._method; } }

		public override MultiMap<string, string> headers { get { return this._headers; } }

		public FastCGIRequest(FastCGI.request request) {
			this.request = request;

			// extract environment variables
			foreach (var variable in this.request.environment.get_all ())
			{
				var parts = variable.split("=");
				this._environment[parts[0]] = parts[1];
			}

			// extract method

			// extract query
			// read status code

			// read headers

			// body's ready to be read now :)
		}

		public override ssize_t read (uint8[] buffer, Cancellable? cancellable = null) {
			return this.request.in.read (buffer);
		}

		public override bool close (Cancellable? cancellable = null) {
			return this.request.in.is_closed;
		}
	}

	public class FastCGIResponse : Response {

		private weak FastCGI.request request;

		private uint _status;
		private string _mime;

		private bool written_headers = false;

		private HashMultiMap _headers = new HashMultiMap<string, string> ();

		public override uint status { get { return this._status; } set { this._status = value; } }

		public override string mime { get { return this._mime;} set { this._mime = value; } }

		public override MultiMap<string, string> headers { get { return this._headers; } }

		public FastCGIResponse(FastCGI.request request) {
			this.request = request;

			// write headers
		}

		public override ssize_t write (uint8[] buffer, Cancellable? cancellable = null) {
			var written = 0;
			foreach (var byte in buffer) {
				written += this.request.out.putc(byte);
			}
			return written;
		}

		public override bool close (Cancellable? cancellable = null) {
			this.request.out.set_exit_status (0);
			return this.request.out.is_closed;
		}
	}

}
