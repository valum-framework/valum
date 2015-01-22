using Gee;
using FastCGI;

/**
 * FastCGI implementation of VSGI.
 */
namespace VSGI {

	/**
	 * FastCGI Request parsed from FastCGI.request struct.
	 */
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

			var reader = new DataInputStream(this);

			reader.newline_type = DataStreamNewlineType.CR_LF;

			// extract method, path and status
			var re = new Regex("^(?<method>\\w+) (?<path>\\w) (?<query>)$");

			MatchInfo match_info;
			assert (re.match(reader.read_line (), 0, out match_info));

			this._uri = new Soup.URI(match_info.fetch_named("query"));

			if (re.match(reader.read_line (), 0, out match_info)) {
				this._method = match_info.fetch_named("method");
				this._path = match_info.fetch_named("path");
			}

			// extract query
			var query = match_info.fetch_named("query");

			// read headers
			var header = "";
			do {
				// will consume the empty line between HEAD and BODY
				header = reader.read_line ();
				if (header.length > 0) {
					var pieces = header.split(":", 1);
					this.headers[pieces[0]] = pieces[1];
				}
			} while (header.length > 0);

			// body's ready to be read now :)
		}

		public override ssize_t read (uint8[] buffer, Cancellable? cancellable = null) {
			return this.request.in.read (buffer);
		}

		public override bool close (Cancellable? cancellable = null) {
			return this.request.out.flush () && this.request.in.is_closed;
		}
	}

	/**
	 * FastCGI Response
	 */
	public class FastCGIResponse : Response {

		private weak FastCGI.request request;

		/**
		 * Tells if the HEAD part of the HTTP message has been written to the
		 * output stream.
		 */
		private bool head_written = false;

		private uint _status;

		private HashMultiMap _headers = new HashMultiMap<string, string> ();

		public override uint status { get { return this._status; } set { this._status = value; } }

		public override string mime { get { return
		this.headers["Content-Type"].to_array()[0]; } set { this.headers["Content-Type"] = value; } }

		public override MultiMap<string, string> headers { get { return this._headers; } }

		public FastCGIResponse(FastCGI.request request) {
			this.request = request;
		}

		public override ssize_t write (uint8[] buffer, Cancellable? cancellable = null) {

			// write head
			if (!this.head_written) {
				// TODO: write the appropriate status message
				this.request.out.printf("HTTP/1.1 %u %s\r\n", this.status, "OK");
				this.headers.map_iterator().foreach((k, v) => {
					this.request.out.printf("%s: %s\r\n", k, v);
					return true;
				});
				this.request.out.puts("\r\n");
				this.head_written = true;
			}

			var written = 0;
			foreach (var byte in buffer) {
				written += this.request.out.putc(byte);
			}
			return written;
		}

		public override bool close (Cancellable? cancellable = null) {
			this.request.out.flush ();
			this.request.close ();
			return this.request.out.is_closed;
		}
	}

	/**
	 * FastCGI Server using GLib.MainLoop.
	 */
	public class FastCGIServer : VSGI.Server {

		public FastCGIServer (VSGI.Application app) {
			base (app);
		}

		public override void listen () {
			var loop = new MainLoop ();

			FastCGI.init ();

			FastCGI.request request;
			FastCGI.request.init (out request);

			var source = new TimeoutSource (0);

			source.set_callback(() => {

				message("accepting a new request...");

				// accept a new request
				var status = request.accept ();

				if (status < 0) {
					warning ("could not accept a request (code %d)", status);
					request.close ();
					loop.quit ();
					return false;
				}

				// handle the request using FastCGI handler
				var req = new VSGI.FastCGIRequest (request);
				var res = new VSGI.FastCGIResponse (request);

				this.application.handler (req, res);

				request.finish ();

				assert (request.in.is_closed);
				assert (request.out.is_closed);

				return true;
			});

			source.attach (loop.get_context ());

			loop.run ();
		}
	}
}
