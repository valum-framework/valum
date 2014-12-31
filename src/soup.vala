using Gee;
using Soup;

namespace Valum {

	// Adapt Soup.MessageHeaders as a MultiMap
	class MessageHeadersMultiMap : Object, MultiMap<string, string> {
		private class MessageHeadersMapIterator : Object, MapIterator <string, string> {
			private MessageHeadersIter iter;
			private string name;
			private string header;
			public bool valid { get { return name != null; } }
	 		public bool mutable { get { return true; } }
			public bool read_only { get { return false; } }
			public bool next () {
				return this.iter.next (out this.name, out this.header);
			}
			public bool has_next () {
				return true;
			}
			public string get_key () {
				return this.name;
			}
			public string get_value () {
				return this.header;
			}
			public void set_value (string header) {
				this.header = header;
			}
			public void unset () {
				this.name = null;
			}
			public MessageHeadersMapIterator(MessageHeaders headers) {
				MessageHeadersIter.init(out this.iter, headers);
			}
		}

		private MessageHeaders headers;
		public int size { get { return 0; } }
		public bool read_only { get { return false;} }
		public MessageHeadersMultiMap(MessageHeaders headers) {
			this.headers = headers;
		}
		public bool contains (string name) {
			return this.headers.get_one (name) != null;
		}
		public bool remove (string name, string header) {
			this.headers.remove (name);
			return true;
		}
		public bool remove_all (string name) {
			this.headers.remove (name);
			return true;
		}
		public void clear () {
			this.headers.clear ();
		}
		public Set<string> get_keys () {
			return new HashSet<string> ();
		}
		public MultiSet<string> get_all_keys () {
			return new HashMultiSet<string> ();
		}
		public Collection<string> get_values () {
			return new HashMultiSet<string> ();
		}
		public new Collection<string> @get(string name) {
			return new ArrayList<string>.wrap (this.headers.get_list(name).split(","));
		}
		public new void @set(string name, string header) {
			this.headers.replace (name, header);
		}
		public MapIterator<string, string> map_iterator () {
			return new MessageHeadersMapIterator (this.headers);
		}
	}

	// Use Soup MessageBody as an InputStream
	class MessageBodyInputStream : InputStream {

		private MessageBody body;

		public MessageBodyInputStream(MessageBody body) {
			this.body = body;
		}

		public override bool close(Cancellable? cancellable = null) {
			this.body.complete();
			return true;
		}

		public override ssize_t read (uint8[] buffer, Cancellable? cancellable = null) {
			buffer = this.body.data;
			return this.body.data.length;
		}
	}

	// Use Soup MessageBody as OutputStream
	class MessageBodyOutputStream : OutputStream {

		private MessageBody body;

		public MessageBodyOutputStream(MessageBody body) {
			this.body = body;
		}

		public override bool close(Cancellable? cancellable = null) {
			this.body.complete();
			return true;
		}

		public override ssize_t write(uint8[] buffer, Cancellable? cancellable = null) {
			this.body.append_take(buffer);
			return buffer.length;
		}
	}

	// libsoup implementation
	public class SoupRequest : SGI.Request {

		private Soup.Message message;
		private MessageHeadersMultiMap _headers;
		private MessageBodyInputStream _body;
		private HashMap<string, string> _query;
		private string _method;

		public override string method { get { return this._method; } }

		public override string path { get { return this.message.uri.get_path (); } }

		public override Map<string, string> query { get { return this._query; } }

		public override MultiMap<string, string> headers { get { return this._headers; } }

		public override InputStream body { get { return this._body; } }

		public SoupRequest(Soup.Message msg, HashMap<string, string> query) {
			this.message = msg;
			this._headers = new MessageHeadersMultiMap(msg.request_headers);
			this._body = new MessageBodyInputStream(msg.request_body);
			this._query = query;
			this._method = msg.method;
		}
	}

	public class SoupResponse : SGI.Response {

		private Soup.Message message;
		private MessageHeadersMultiMap _headers;
		private MessageBodyOutputStream _body;

		public override string mime {
			get { return this.message.response_headers.get_content_type(null); }
			set { this.message.response_headers.set_content_type(value, null); }
		}

		public override uint status {
			get { return this.message.status_code; }
			set { this.message.set_status(value); }
		}

		public override MultiMap<string, string> headers { get { return this._headers; } }

		public override OutputStream body { get { return this._body; } }

		public SoupResponse(Soup.Message msg) {
			this.message = msg;
			this._headers = new MessageHeadersMultiMap(msg.response_headers);
			this._body = new MessageBodyOutputStream(msg.response_body);
		}

		public void append(string str) {
			this.message.response_body.append_take(str.data);
		}
	}
}
