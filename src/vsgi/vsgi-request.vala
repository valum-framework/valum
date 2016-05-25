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

namespace VSGI {
	/**
	 * Request representing a request of a resource.
	 *
	 * @since 0.0.1
	 */
	public abstract class Request : Object {

		/**
		 * HTTP/1.1 standard methods.
		 *
		 * [[http://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html]]
		 *
		 * @since 0.1
		 */
		public const string OPTIONS = "OPTIONS";
		public const string GET     = "GET";
		public const string HEAD    = "HEAD";
		public const string POST    = "POST";
		public const string PUT     = "PUT";
		public const string DELETE  = "DELETE";
		public const string TRACE   = "TRACE";
		public const string CONNECT = "CONNECT";

		/**
		 * PATCH method defined in RFC5789.
		 *
		 * [[http://tools.ietf.org/html/rfc5789]]
		 *
		 * This is a proposed standard, it is not part of the current HTTP/1.1
		 * protocol.
		 *
		 * @since 0.1
		 */
		public const string PATCH = "PATCH";

		/**
		 * List of all supported HTTP methods.
		 *
		 * @since 0.1
		 */
		public const string[] METHODS = {OPTIONS, GET, HEAD, POST, PUT, DELETE, TRACE, CONNECT, PATCH};

		/**
		 * Connection containing raw streams.
		 *
		 * @since 0.2
		 */
		public IOStream connection { construct; get; }

		/**
		 * Request HTTP version.
		 */
		public abstract HTTPVersion http_version { get; }

		/**
		 * Identifier for the gateway (eg. CGI/1.1).
		 *
		 * It is composed of an identifier and a version number separated by a
		 * slash '/'.
		 *
		 * @since 0.3
		 */
		public abstract string gateway_interface { owned get; }

		/**
		 * Request HTTP method
		 *
		 * Should be one of OPTIONS, GET, HEAD, POST, PUT, DELETE, TRACE, CONNECT
		 * or PATCH.
		 *
		 * Constants for every standard HTTP methods are providen as constants in
		 * this class.
		 *
		 * @since 0.0.1
		 */
		public abstract string method { owned get; }

		/**
		 * Request URI.
         *
		 * The URI, protocol and HTTP query and other request information is
		 * made available through this property.
		 *
		 * @since 0.1
		 */
		public abstract URI uri { get; }

		/**
		 * HTTP query.
		 *
		 * This is null if the query hasn't been set.
		 *
		 * /path/? empty query
		 * /path/  null query
		 *
		 * @since 0.1
		 */
		public abstract HashTable<string, string>? query { get; }

		/**
		 * Lookup a key in the request query.
		 *
		 * @since 0.3
		 *
		 * @param key     key to lookup
		 * @return the corresponding value if found, otherwise 'null'
		 */
		public string? lookup_query (string key) {
			return query == null ? null : query[key];
		}

		/**
		 * Request headers.
		 *
		 * @since 0.0.1
		 */
		public abstract MessageHeaders headers { get; }

		/**
		 * Request cookies extracted from the 'Cookie' header.
		 *
		 * @since 0.3
		 */
		public SList<Cookie> cookies {
			owned get {
				var cookies     = new SList<Cookie> ();
				var cookie_list = headers.get_list ("Cookie");

				if (cookie_list == null)
					return cookies;

				foreach (var cookie in header_parse_list (cookie_list))
					if (cookie != null)
						cookies.prepend (Cookie.parse (cookie, uri));

				cookies.reverse ();

				return cookies;
			}
		}

		/**
		 * Lookup a cookie using its name.
		 *
		 * The last occurence is returned using a case-sensitive match.
		 *
		 * @since 0.3
		 *
		 * @param name name of the cookie to lookup
		 * @return the cookie if found, otherwise 'null'
		 */
		public Cookie? lookup_cookie (string name) {
			Cookie? found = null;

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
		 * @since 0.3
		 * @return the signed cookie if found, otherwise 'null'
		 */
		public Cookie? lookup_signed_cookie (string       name,
		                                     ChecksumType checksum_type,
		                                     uint8[]      key,
		                                     out string?  @value) {
			Cookie? found = null;
			@value        = null;

			foreach (var cookie in cookies)
				if (cookie.name == name && CookieUtils.verify (cookie, checksum_type, key, out @value))
					found = cookie;

			return found;
		}

		/**
		 * Placeholder for the request body.
		 *
		 * @since 0.3
		 */
		protected InputStream? _body = null;

		/**
		 * Request body.
		 *
		 * The provided stream is filtered by the implementation according to
		 * the 'Transfer-Encoding' header value.
		 *
		 * The default implementation returns the connection stream unmodified.
		 *
		 * @since 0.2
		 */
		public InputStream body {
			get {
				return _body ?? this.connection.input_stream;
			}
		}

		/**
		 * Apply a converter to the request body.
		 *
		 * If the payload is chunked, (eg. 'Transfer-Encoding: chunked') and the
		 * new content length is undetermined, it will remain chunked.
		 *
		 * @since 0.3
		 *
		 * @param content_length resulting value for the 'Content-Length' header,
		 *                       '0' for a void-like sink or '-1' if the length
		 *                       is undetermined
		 */
		public void convert (Converter converter, int64 content_length = -1) {
			if (content_length > 0) {
				headers.set_content_length (content_length);
			} else if (content_length == 0) {
				headers.set_encoding (Soup.Encoding.NONE);
			} else if (headers.get_encoding () == Soup.Encoding.CHUNKED) {
				// nothing to do
			} else {
				headers.set_encoding (Soup.Encoding.EOF);
			}
			_body = new ConverterInputStream (_body ?? connection.input_stream, converter);
		}

		/**
		 * Buffer the body stream.
		 *
		 * This function consumes the body stream. Any subsequent calls will
		 * yield an empty buffer.
		 *
		 * If the 'Content-Length' header is set, a fixed-size buffer is used
		 * instead of dynamically resizing the buffer to fit the stream content.
		 *
		 * @since 0.2.3
		 *
		 * @return buffer containing the stream data
		 */
		public uint8[] flatten (Cancellable? cancellable = null) throws IOError {
			var buffer = this.headers.get_encoding () == Encoding.CONTENT_LENGTH ?
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
		 * @since 0.2.3
		 */
		public Bytes flatten_bytes (Cancellable? cancellable = null) throws IOError {
			return new Bytes.take (flatten (cancellable));
		}

		/**
		 * @since 0.2.4
		 */
		public string flatten_utf8 (Cancellable? cancellable = null) throws IOError {
			return (string) flatten (cancellable);
		}

		/**
		 * Buffer the body stream asynchronously.
		 *
		 * @since 0.2.3
		 *
		 * @return buffer containing the stream data
		 */
		public async uint8[] flatten_async (int io_priority = GLib.Priority.DEFAULT,
		                                    Cancellable? cancellable = null) throws IOError {
			var buffer = this.headers.get_encoding () == Encoding.CONTENT_LENGTH ?
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

		/**
		 * @since 0.2.3
		 */
		public async Bytes flatten_bytes_async (int io_priority = GLib.Priority.DEFAULT,
		                                        Cancellable? cancellable = null) throws IOError {
			return new Bytes.take (yield flatten_async (io_priority, cancellable));
		}

		/**
		 * @since 0.2.4
		 */
		public async string flatten_utf8_async (int io_priority = GLib.Priority.DEFAULT,
		                                        Cancellable? cancellable = null) throws IOError {
			return (string) yield flatten_async (io_priority, cancellable);
		}
	}
}
