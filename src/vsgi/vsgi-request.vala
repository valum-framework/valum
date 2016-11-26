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

namespace VSGI {

	/**
	 * Request representing a request of a resource.
	 */
	[Version (since = "0.1")]
	public class Request : Object {

		/**
		 * HTTP/1.1 standard methods.
		 *
		 * [[http://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html]]
		 */
		[Version (since = "0.1", experimental = true)]
		public const string OPTIONS = "OPTIONS";
		[Version (since = "0.1", experimental = true)]
		public const string GET     = "GET";
		[Version (since = "0.1", experimental = true)]
		public const string HEAD    = "HEAD";
		[Version (since = "0.1", experimental = true)]
		public const string POST    = "POST";
		[Version (since = "0.1", experimental = true)]
		public const string PUT     = "PUT";
		[Version (since = "0.1", experimental = true)]
		public const string DELETE  = "DELETE";
		[Version (since = "0.1", experimental = true)]
		public const string TRACE   = "TRACE";
		[Version (since = "0.1", experimental = true)]
		public const string CONNECT = "CONNECT";

		/**
		 * PATCH method defined in RFC5789.
		 *
		 * [[http://tools.ietf.org/html/rfc5789]]
		 *
		 * This is a proposed standard, it is not part of the current HTTP/1.1
		 * protocol.
		 */
		[Version (since = "0.1", experimental = true)]
		public const string PATCH = "PATCH";

		/**
		 * List of all supported HTTP methods.
		 */
		[Version (since = "0.1", experimental = true)]
		public const string[] METHODS = {OPTIONS, GET, HEAD, POST, PUT, DELETE, TRACE, CONNECT, PATCH};

		/**
		 * Connection containing raw streams.
		 */
		[Version (since = "0.2")]
		public IOStream connection { construct; get; }

		/**
		 * Request HTTP version.
		 */
		[Version (since = "0.3")]
		public Soup.HTTPVersion http_version { get; construct; default = Soup.HTTPVersion.@1_1; }

		/**
		 * Identifier for the gateway (eg. CGI/1.1).
		 *
		 * It is composed of an identifier and a version number separated by a
		 * slash '/'.
		 */
		[Version (since = "0.3")]
		public string gateway_interface { get; construct; }

		/**
		 * Tell if this is a CGI-like protocol.
		 */
		public bool is_cgi { get; construct; default = false; }

		/**
		 * CGI environment if this is a CGI-like protocol.
		 */
		[CCode (array_length = false, array_null_terminated = true)]
		public string[] environment { get; construct; default = {}; }

		/**
		 * Request HTTP method
		 *
		 * Should be one of OPTIONS, GET, HEAD, POST, PUT, DELETE, TRACE, CONNECT
		 * or PATCH.
		 *
		 * Constants for every standard HTTP methods are providen as constants in
		 * this class.
		 */
		[Version (since = "0.1")]
		public string method { get; construct; default = "GET"; }

		/**
		 * Request URI.
         *
		 * The URI, protocol and HTTP query and other request information is
		 * made available through this property.
		 */
		[Version (since = "0.1")]
		public Soup.URI uri { get; construct; }

		/**
		 * HTTP query parsed if encoded according to percent-encoding,
		 * otherwise it must be interpreted from {@link VSGI.Request.uri}
		 *
		 * It is 'null' if the query hasn't been set, which is different than an
		 * empty query (eg. '/path/?' instead of '/path/')
		 */
		[Version (since = "0.1")]
		public HashTable<string, string>? query { get; construct set; default = null; }

		/**
		 * Lookup a key in the request query.
		 *
		 * If the query itself is 'null' or the key is not available
		 *
		 * @param key key to lookup
		 */
		[Version (since = "0.3")]
		public string? lookup_query (string key) {
			return query == null ? null : query[key];
		}

		/**
		 * Request headers.
		 */
		[Version (since = "0.1")]
		public Soup.MessageHeaders headers { get; construct; default = new Soup.MessageHeaders (Soup.MessageHeadersType.REQUEST); }

		/**
		 * Request cookies extracted from the 'Cookie' header.
		 */
		[Version (since = "0.3")]
		public SList<Soup.Cookie> cookies {
			owned get {
				var cookies     = new SList<Soup.Cookie> ();
				var cookie_list = headers.get_list ("Cookie");

				if (cookie_list == null)
					return cookies;

				foreach (var cookie in Soup.header_parse_list (cookie_list))
					if (cookie != null)
						cookies.prepend (Soup.Cookie.parse (cookie, uri));

				cookies.reverse ();

				return cookies;
			}
		}

		/**
		 * Lookup a cookie using its name.
		 *
		 * The last occurence is returned using a case-sensitive match.
		 *
		 * @param name name of the cookie to lookup
		 * @return the cookie if found, otherwise 'null'
		 */
		[Version (since = "0.3")]
		public Soup.Cookie? lookup_cookie (string name) {
			Soup.Cookie? found = null;

			foreach (var cookie in cookies)
				if (cookie.name == name)
					found = cookie;

			return found;
		}

		/**
		 * Lookup a signed cookie using its name.
		 *
		 * The returned cookie has its value signed, the 'value' parameter can
		 * be used to obtain its original value.
		 *
		 * @see CookieUtils.verify
		 *
		 * @return the signed cookie if found, otherwise 'null'
		 */
		[Version (since = "0.3")]
		public Soup.Cookie? lookup_signed_cookie (string       name,
		                                     ChecksumType checksum_type,
		                                     uint8[]      key,
		                                     out string?  @value) {
			Soup.Cookie? found = null;
			@value        = null;

			foreach (var cookie in cookies)
				if (cookie.name == name && CookieUtils.verify (cookie, checksum_type, key, out @value))
					found = cookie;

			return found;
		}

		private InputStream _body = null;

		/**
		 * Request body.
		 *
		 * The provided stream is filtered by the implementation according to
		 * the 'Transfer-Encoding' header value.
		 *
		 * The default implementation returns the connection stream unmodified.
		 */
		[Version (since = "0.2")]
		public InputStream body {
			owned get {
				return new BodyInputStream (this, _body);
			}
			construct {
				_body = value ?? connection.input_stream;
			}
		}

		[Version (experimental = true)]
		public Request (IOStream                   connection,
		                string                     method,
		                Soup.URI                   uri,
		                HashTable<string, string>? query = null,
		                InputStream?               body  = null) {
			base (connection: connection,
			      method:     method,
			      uri:        uri,
			      query:      query,
			      body:       body);
		}

		[Version (experimental = true)]
		public Request.with_method (string method, Soup.URI uri) {
			base (connection: new SimpleIOStream (new MemoryInputStream (), new MemoryOutputStream.resizable ()),
			      method:     method,
			      uri:        uri);
		}

		[Version (experimental = true)]
		public Request.with_uri (Soup.URI uri) {
			base (connection: new SimpleIOStream (new MemoryInputStream (), new MemoryOutputStream.resizable ()),
			      uri:        uri);
		}

		[Version (experimental = true)]
		public Request.with_query (HashTable<string, string>? query) {
			base (connection: new SimpleIOStream (new MemoryInputStream (), new MemoryOutputStream.resizable ()),
			      query:      query);
		}

		[Version (experimental = true)]
		public Request.from_cgi_environment (IOStream connection, string[] environment, InputStream? body = null) {
			base (connection:        connection,
			      uri:               new Soup.URI ("http://localhost/"),
			      http_version:      Environ.get_variable (environment, "SERVER_PROTOCOL") == "HTTP/1.1" ? Soup.HTTPVersion.@1_1 : Soup.HTTPVersion.@1_0,
			      gateway_interface: Environ.get_variable (environment, "GATEWAY_INTERFACE") ?? "CGI/1.1",
			      is_cgi:            true,
			      environment:       environment,
			      method:            Environ.get_variable (environment, "REQUEST_METHOD") ?? "GET",
			      body:              body);

			var https           = Environ.get_variable (environment, "HTTPS");
			var path_translated = Environ.get_variable (environment, "PATH_TRANSLATED");
			if (https != null && https.length > 0 || path_translated != null && path_translated.has_prefix ("https://"))
				uri.set_scheme ("https");
			else
				uri.set_scheme ("http");

			uri.set_user (Environ.get_variable (environment, "REMOTE_USER"));
			uri.set_host (Environ.get_variable (environment, "SERVER_NAME"));

			var port = Environ.get_variable (environment, "SERVER_PORT");
			if (port != null)
				uri.set_port (int.parse (port));

			var path_info   = Environ.get_variable (environment, "PATH_INFO");
			var request_uri = Environ.get_variable (environment, "REQUEST_URI");
			if (path_info != null && path_info.length > 0)
				uri.set_path (path_info);
			else if (request_uri != null && request_uri.length > 0)
				uri.set_path (request_uri.split ("?", 2)[0]); // strip the query
			else
				uri.set_path ("/");

			// raw & parsed HTTP query
			var query_string = Environ.get_variable (environment, "QUERY_STRING");
			if (query_string != null && query_string.length > 0) {
				uri.set_query (query_string);
				query = Soup.Form.decode (query_string);
			} else if (path_translated != null && "?" in path_translated) {
				uri.set_query (path_translated.split ("?", 2)[1]);
				query = Soup.Form.decode (path_translated.split ("?", 2)[1]);
			} else if (request_uri != null && "?" in request_uri) {
				uri.set_query (request_uri.split ("?", 2)[1]);
				query = Soup.Form.decode (request_uri.split ("?", 2)[1]);
			}

			var content_type = Environ.get_variable (environment, "CONTENT_TYPE") ?? "application/octet-stream";
			var @params = Soup.header_parse_param_list (content_type);
			headers.set_content_type (content_type.split (";", 2)[0], @params);

			//
			int64 content_length;
			if (int64.try_parse (Environ.get_variable (environment, "CONTENT_LENGTH") ?? "0",
			                     out content_length)) {
				headers.set_content_length (content_length);
			}

			// extract HTTP headers, they are prefixed by 'HTTP_' in environment variables
			foreach (var variable in environment) {
				var parts = variable.split ("=", 2);
				if (parts[0].has_prefix ("HTTP_")) {
					this.headers.append (parts[0].substring (5).replace ("_", "-").casefold (), parts[1]);
				}
			}
		}

		construct {
			if (_method == null) {
				_method = "GET";
			}
			if (_headers == null) {
				_headers = new Soup.MessageHeaders (Soup.MessageHeadersType.REQUEST);
			}
		}

		/**
		 * Apply a converter to the request body.
		 *
		 * If the payload is chunked, (eg. 'Transfer-Encoding: chunked') and the
		 * new content length is undetermined, it will remain chunked.
		 *
		 * @param content_length resulting value for the 'Content-Length' header
		 *                       or '-1' if the length is undetermined
		 */
		[Version (since = "0.3")]
		public void convert (Converter converter, int64 content_length = -1) {
			if (content_length >= 0) {
				headers.set_content_length (content_length);
			} else if (headers.get_encoding () == Soup.Encoding.CHUNKED) {
				// nothing to do
			} else {
				headers.set_encoding (Soup.Encoding.EOF);
			}
			_body = new ConverterInputStream (_body ?? connection.input_stream, converter);
		}

		/**
		 * Flatten the request body in a buffer.
		 *
		 * This function consumes the body stream. Any subsequent calls will
		 * yield an empty buffer.
		 *
		 * If the 'Content-Length' header is set, a fixed-size buffer is used
		 * instead of dynamically resizing the buffer to fit the stream content.
		 *
		 * @return buffer containing the stream data
		 */
		[Version (since = "0.2")]
		public virtual uint8[] flatten (Cancellable? cancellable = null) throws IOError {
			var buffer = this.headers.get_encoding () == Soup.Encoding.CONTENT_LENGTH ?
				new MemoryOutputStream (new uint8[this.headers.get_content_length ()], null, free) :
				new MemoryOutputStream (null, realloc, free);

			buffer.splice (this.body,
			               OutputStreamSpliceFlags.CLOSE_SOURCE | OutputStreamSpliceFlags.CLOSE_TARGET,
			               cancellable);

			var data = buffer.steal_data ();
			data.length = (int) buffer.get_data_size ();

			return data;
		}

		/**
		 * Flatten the request body as a {@link GLib.Bytes}.
		 */
		[Version (since = "0.2")]
		public Bytes flatten_bytes (Cancellable? cancellable = null) throws IOError {
			return new Bytes.take (flatten (cancellable));
		}

		/**
		 * Flatten the request body as a 'UTF-8' string.
		 *
		 * The payload is assumed to be encoded according to 'UTF-8'. If it is
		 * not the case, use {@link VSGI.Request.flatten} directly instead.
		 */
		[Version (since = "0.2")]
		public string flatten_utf8 (Cancellable? cancellable = null) throws IOError {
			return (string?) flatten (cancellable) ?? "";
		}

		/**
		 * Buffer the body stream asynchronously.
		 *
		 * @return buffer containing the stream data
		 */
		[Version (since = "0.2")]
		public virtual async uint8[] flatten_async (int io_priority = GLib.Priority.DEFAULT,
		                                    Cancellable? cancellable = null) throws IOError {
			var buffer = this.headers.get_encoding () == Soup.Encoding.CONTENT_LENGTH ?
				new MemoryOutputStream (new uint8[this.headers.get_content_length ()], null, free) :
				new MemoryOutputStream (null, realloc, free);

			yield buffer.splice_async (this.body,
			                           OutputStreamSpliceFlags.CLOSE_SOURCE | OutputStreamSpliceFlags.CLOSE_TARGET,
			                           io_priority,
			                           cancellable);

			var data = buffer.steal_data ();
			data.length = (int) buffer.get_data_size ();

			return data;
		}

		[Version (since = "0.2")]
		public async Bytes flatten_bytes_async (int io_priority = GLib.Priority.DEFAULT,
		                                        Cancellable? cancellable = null) throws IOError {
			return new Bytes.take (yield flatten_async (io_priority, cancellable));
		}

		[Version (since = "0.2")]
		public async string flatten_utf8_async (int io_priority = GLib.Priority.DEFAULT,
		                                        Cancellable? cancellable = null) throws IOError {
			return ((string?) yield flatten_async (io_priority, cancellable)) ?? "";
		}

		private class BodyInputStream : FilterInputStream {

			public Request request { get; construct; }

			public BodyInputStream (Request request, InputStream base_stream) {
				Object (request: request, base_stream: base_stream, close_base_stream: false);
			}

			public override ssize_t read (uint8[] buffer, Cancellable? cancellable = null) throws IOError {
				return base_stream.read (buffer, cancellable);
			}

			public override bool close (Cancellable? cancellable = null) throws IOError {
				return base_stream.close (cancellable);
			}

			public override void dispose () {
				// prevent close-on-dispose
			}
		}
	}
}
