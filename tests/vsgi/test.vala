using Soup;

/**
 * Test implementation of VSGI.
 */
namespace VSGI.Test {
	/**
	 * Test implementation of Request used to stub a request.
	 */
	public class Request : VSGI.Request {

		private HTTPVersion _http_version         = HTTPVersion.@1_1;
		private string _method                    = VSGI.Request.GET;
		private URI _uri                          = new URI (null);
		private MessageHeaders _headers           = new MessageHeaders (MessageHeadersType.REQUEST);
		private HashTable<string, string>? _query = null;

		public override HTTPVersion http_version { get { return this._http_version; } }

		public override string method { owned get { return this._method; } }

		public override URI uri { get { return this._uri; } }

		public override HashTable<string, string>? query { get { return this._query; } }

		public override MessageHeaders headers {
			get {
				return this._headers;
			}
		}

		public Request (string method, URI uri, HashTable<string, string>? query = null) {
			Object (connection: new SimpleIOStream (new MemoryInputStream (), new MemoryOutputStream (null, realloc, free)));
			this._method = method;
			this._uri    = uri;
			this._query  = query;
		}

		public Request.with_method (string method) {
			Object (connection: new SimpleIOStream (new MemoryInputStream (), new MemoryOutputStream (null, realloc, free)));
			this._method = method;
		}

		public Request.with_uri (URI uri) {
			Object (connection: new SimpleIOStream (new MemoryInputStream (), new MemoryOutputStream (null, realloc, free)));
			this._uri = uri;
		}

		public Request.with_query (HashTable<string, string>? query) {
			Object (connection: new SimpleIOStream (new MemoryInputStream (), new MemoryOutputStream (null, realloc, free)));
			this._query = query;
		}
	}

	/**
	 * Test implementation of VSGI.Response to stub a response.
	 */
	public class Response : VSGI.Response {

		private uint _status;
		private MessageHeaders _headers = new MessageHeaders (MessageHeadersType.RESPONSE);

		public override uint status { get { return this._status; } set { this._status = value; } }

		public override MessageHeaders headers {
			get {
				return this._headers;
			}
		}

		public Response (Request req, uint status) {
			Object (request: req, connection: new SimpleIOStream (new MemoryInputStream (),
																  new MemoryOutputStream (null, realloc, free)));
			this._status = status;
		}
	}
}
