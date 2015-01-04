using Gee;
using Soup;

namespace VSGI {

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

	// libsoup implementation
	public class SoupRequest : VSGI.Request {

		private Soup.Message message;
		private MessageHeadersMultiMap _headers;
		private HashMap<string, string> _query;
		private string _method;

		public override string method { get { return this._method; } }

		public override URI uri { get { return this.message.uri; } }

		public override MultiMap<string, string> headers { get { return this._headers; } }

		public SoupRequest(Soup.Message msg) {
			this.message = msg;
			this._method = msg.method;
			this._headers = new MessageHeadersMultiMap(msg.request_headers);
		}

		public override ssize_t read (uint8[] buffer, Cancellable? cancellable = null) {
			buffer = this.message.request_body.data;
			return this.message.request_body.data.length;
		}

		public override bool close(Cancellable? cancellable = null) {
			this.message.request_body.complete();
			return true;
		}
	}

	public class SoupResponse : VSGI.Response {

		private Soup.Message message;
		private MessageHeadersMultiMap _headers;

		public override string mime {
			get { return this.message.response_headers.get_content_type(null); }
			set { this.message.response_headers.set_content_type(value, null); }
		}

		public override uint status {
			get { return this.message.status_code; }
			set { this.message.set_status(value); }
		}

		public override MultiMap<string, string> headers { get { return this._headers; } }

		public SoupResponse(Soup.Message msg) {
			this.message = msg;
			this._headers = new MessageHeadersMultiMap(msg.response_headers);
		}

		public override ssize_t write(uint8[] buffer, Cancellable? cancellable = null) {
			this.message.response_body.append_take(buffer);
			return buffer.length;
		}

		public override bool close(Cancellable? cancellable = null) {
			this.message.response_body.complete();
			return true;
		}
	}
}
