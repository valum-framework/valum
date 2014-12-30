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

		public MessageHeaders headers { construct; get; }
		public int size { get { return 0; } }
		public bool read_only { get { return false;} }
		public MessageHeadersMultiMap(MessageHeaders headers) {
			Object(headers : headers);
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

		public MessageBody body { construct; get; }

		public MessageBodyInputStream(MessageBody body) {
			Object(body: body);
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

		public MessageBody body { construct; get; }

		public MessageBodyOutputStream(MessageBody body) {
			Object(body: body);
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
	public class SoupRequest : Request {

		public Soup.Message message { construct; get; }

		public SoupRequest(Soup.Message msg) {
			var headers = new MessageHeadersMultiMap(msg.request_headers);
			var body = new DataInputStream(new MessageBodyInputStream(msg.request_body));
			Object(message: msg, path: msg.uri.get_path (), method: msg.method, headers: headers, body: body);
		}
	}

	public class SoupResponse : Response {

		public Soup.Message message { construct; get; }

		public override string mime {
			get { return this.message.response_headers.get_content_type(null); }
			set { this.message.response_headers.set_content_type(value, null); }
		}

		public override uint status {
			get { return this.message.status_code; }
			set { this.message.set_status(value); }
		}

		public SoupResponse(Soup.Message msg) {
			var headers = new MessageHeadersMultiMap(msg.response_headers);
			var body = new DataOutputStream(new MessageBodyOutputStream(msg.response_body));
			Object(message: msg, headers: headers, body: body);
		}

		public void append(string str) {
			this.message.response_body.append_take(str.data);
		}
	}
}
