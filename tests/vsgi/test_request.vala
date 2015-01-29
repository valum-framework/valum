/**
 * Test implementation of Request used to stub a request.
 */
public class TestRequest : VSGI.Request {

	private string _method;
	private Soup.URI _uri;
	private Soup.MessageHeaders _headers;
	private HashTable<string, string> _query;

	public override string method { owned get { return this._method; } }

	public override Soup.URI uri { get { return this._uri; } }

	public override HashTable<string, string>? query { get { return this._query; } }

	public override Soup.MessageHeaders headers {
		get {
			return this._headers;
		}
	}

	public TestRequest (string method, Soup.URI uri, HashTable<string, string>? query = null) {
		this._method = method;
		this._uri    = uri;
		this._query  = query;
	}

	public TestRequest.with_method (string method) {
		this._method = method;
	}

	public TestRequest.with_uri (Soup.URI uri) {
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
