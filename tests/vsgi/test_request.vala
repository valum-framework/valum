using Soup;

/**
 * Test implementation of Request used to stub a request.
 */
public class TestRequest : VSGI.Request {

	private string _method                    = VSGI.Request.GET;
	private URI _uri                          = new Soup.URI (null);
	private MessageHeaders _headers           = new MessageHeaders (MessageHeadersType.REQUEST);
	private HashTable<string, string>? _query = null;

	public override string method { owned get { return this._method; } }

	public override URI uri { get { return this._uri; } }

	public override HashTable<string, string>? query { get { return this._query; } }

	public override MessageHeaders headers {
		get {
			return this._headers;
		}
	}

	public TestRequest (string method, URI uri, HashTable<string, string>? query = null) {
		this._method = method;
		this._uri    = uri;
		this._query  = query;
	}

	public TestRequest.with_method (string method) {
		this._method = method;
	}

	public TestRequest.with_uri (URI uri) {
		this._uri = uri;
	}

	public TestRequest.with_query (HashTable<string, string>? query) {
		this._query = query;
	}

	public override ssize_t read (uint8[] buffer, Cancellable? cancellable = null) {
		return 0;
	}

	public override bool close (Cancellable? cancellable = null) {
		return true;
	}
}
