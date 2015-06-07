/*
 * This file is part of Valum.
 *
 * Valum is free software: you can redistribute it and/or modify it under the
 * terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) any
 * later version.
 *
 * Valum is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with Valum.  If not, see <http://www.gnu.org/licenses/>.
 */

using GLib;
using Soup;

/**
 * Mocked implementation of VSGI to perform unit and integration testing with
 * VSGI-compliant applications.
 *
 * It consists of basic {@link VSGI.Request} and {@link VSGI.Response}
 * implementations and a simple client to perform interactive tests.
 *
 * @since 0.1
 */
namespace VSGI.Test {

	/**
	 *
	 */
	public class Connection : IOStream {

		private MemoryInputStream _input_stream;
		private MemoryOutputStream _output_stream;

		public override InputStream input_stream { get { return this._input_stream; } }

		public override OutputStream output_stream { get { return this._output_stream; } }

		public Connection () {
			this._input_stream  = new MemoryInputStream ();
			this._output_stream = new MemoryOutputStream (null, realloc, free);
		}
	}

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
			Object (connection: new Connection ());
			this._method = method;
			this._uri    = uri;
			this._query  = query;
		}

		public Request.with_http_version (HTTPVersion http_version) {
			this._http_version = http_version;
		}

		public Request.with_method (string method) {
			Object (connection: new Connection ());
			this._method = method;
		}

		public Request.with_uri (URI uri) {
			Object (connection: new Connection ());
			this._uri = uri;
		}

		public Request.with_query (HashTable<string, string>? query) {
			Object (connection: new Connection ());
			this._query = query;
		}
	}

	public class Response : VSGI.Response {

		private uint _status;
		private MessageHeaders _headers = new MessageHeaders (MessageHeadersType.RESPONSE);

		public override uint status {
			get { return this._status; }
			set { this._status = value; }
		}

		public override MessageHeaders headers {
			get {
				return this._headers;
			}
		}

		public Response (Request req, uint status) {
			Object (request: req);
			this._status = status;
		}
	}

	/**
	 * Client designed to perform a sequence of requests on a compliant VSGI
	 * application.
	 *
	 * @since 0.1
	 */
	public class Client : Object {

		public VSGI.Application application { construct; get; }

		private MainLoop loop = new MainLoop ();

		public Client (VSGI.Application application) {
			Object (application: application);
		}

		public Client.with_timeout (VSGI.Application application, uint timeout) {
			Object (application: application, timeout: timeout);

			var timeout = new TimeoutSource (this.pending);

			timeout.set_callback (() => {
				assert_not_reached ();
				return false;
			});

			timeout.attach (loop.get_context ());
		}

		/**
		 * Process pending asynchronous tasks when the client is no longer
		 * required.
		 */
		~Client () {
			loop.run ();
		}

		public RequestBuilder @get (string uri) {
			return new RequestBuilder ()
				.set_uri (uri);
		}

		public RequestBuilder post (string uri) {
			return new RequestBuilder ()
				.set_uri (uri);
		}

		/**
		 * Provide facilities to build a request out of scratches.
		 *
		 * @since 0.2
		 */
		public class RequestBuilder : Object {

			private uint timeout = 5000;

			private HTTPVersion http_version         = HTTPVersion.@1_1;
			private string method                    = VSGI.Request.GET;
			private URI uri                          = new URI (null);
			private MessageHeaders headers           = new MessageHeaders (MessageHeadersType.REQUEST);
			private HashTable<string, string>? query = null;
			private MemoryInputStream body           = new MemoryInputStream ();

			/**
			 * @since 0.2
			 */
			public delegate void URICallback (URI uri);

			/**
			 * @since 0.2
			 */
			public delegate void HeadersCallback (MessageHeaders uri);

			/**
			 * @since 0.2
			 */
			public delegate void QueryCallback (HashTable<string, string> query);

			/**
			 * @since 0.2
			 */
			public delegate void ResponseCallback (Response res);

			/**
			 * @since 0.2
			 */
			public RequestBuilder set_timeout (uint ms) {
				this.timeout = ms;
				return this;
			}

			/**
			 * @since 0.2
			 */
			public RequestBuilder set_http_version (HTTPVersion http_version) {
				this.http_version = http_version;
				return this;
			}

			/**
			 * @since 0.2
			 */
			public RequestBuilder set_method (string method) {
				this.method = method;
				return this;
			}

			/**
			 * @since 0.2
			 */
			public RequestBuilder set_uri (URI uri) {
				this.uri = uri;
				return this;
			}

			/**
			 * Edit the URI in a closure.
			 *
			 * @since 0.2
			 */
			public RequestBuilder edit_uri (URICallback uc) {
				uc (this.uri);
				return this;
			}

			/**
			 * @since 0.2
			 */
			public RequestBuilder set_query () {
				this.query = query;
				return this;
			}

			/**
			 * Edit the HTTP query in a closure.
			 *
			 * @since 0.2
			 */
			public RequestBuilder edit_query (QueryCallback qc) {
				// might have been nullified
				if (this.query == null)
					this.query = new HashTable<string, string> (str_hash, str_equal);
				qc (this.query);
				return this;
			}

			/**
			 * @since 0.2
			 */
			public RequestBuilder edit_headers (HeadersCallback hc) {
				hc (this.headers);
				return this;
			}

			/**
			 * @since 0.2
			 */
			public RequestBuilder set_cookies (SList<Cookie> cookies) {
				this.cookies = cookies;
				return this;
			}

			/**
			 * @since 0.2
			 */
			public RequestBuilder set_body (uint8[] body) {
				this.body.set_data (body);
				return this;
			}

			/**
			 * @since 0.2
			 */
			public Request build () {
				return new Request (http_version, method, uri, headers, query);
			}

			/**
			 * Execute the built {@link VSGI.Request} on the provided
			 * application.
			 *
			 * A {@link MainLoop} is used to process asynchronous tasks so that
			 * this function can synchronously wait and return.
			 *
			 * If the timeout is past, {@link assert_not_reached} will be called
			 * to terminate the tests execution.
			 *
			 * @since 0.2
			 */
			public Response execute (ResponseCallback rc) {
				var req = this.build ();
				var res = new Response (200);

				// register a request-specific timeout
				if (timeout > 0)


				res.end.connect_after (() => {
					rc (res);
					loop.quit ();
				});

				application.handle (req, res);
			}
		}
	}
}
