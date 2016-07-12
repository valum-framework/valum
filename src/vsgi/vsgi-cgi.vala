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
 * CGI implementation of VSGI.
 *
 * This implementation is sufficiently general to implement other CGI-like
 * protocol such as FastCGI and SCGI.
 *
 * @since 0.3
 */
namespace VSGI.CGI {

	/**
	 * CGI request providing consistent environment behaviours.
	 *
	 * @since 0.3
	 */
	public class Request : VSGI.Request {

		/**
		 * CGI environment variables encoded in 'NAME=VALUE'.
		 *
		 * @since 0.3
		 */
		public string[] environment { construct; get; }

		private URI _uri                          = new URI (null);
		private HashTable<string, string>? _query = null;
		private MessageHeaders _headers           = new MessageHeaders (MessageHeadersType.REQUEST);

		public override HTTPVersion http_version {
			get {
				return Environ.get_variable (environment, "SERVER_PROTOCOL") == "HTTP/1.1" ?  HTTPVersion.@1_1 :
				                                                                              HTTPVersion.@1_0;
			}
		}

		public override string gateway_interface {
			owned get {
				return Environ.get_variable (environment, "GATEWAY_INTERFACE") ?? "CGI/1.1";
			}
		}

		public override string method {
			owned get {
				return Environ.get_variable (environment, "REQUEST_METHOD") ?? "GET";
			}
		}

		public override URI uri { get { return this._uri; } }

		public override HashTable<string, string>? query {
			get {
				return this._query;
			}
		}

		public override MessageHeaders headers {
			get { return this._headers; }
		}

		/**
		 * Create a request from the provided environment variables.
		 *
		 * Although not part of CGI/1.1 specification, the 'REQUEST_URI' and
		 * 'HTTPS' environment variables are reckognized.
		 *
		 * {@inheritDoc}
		 *
		 * @since 0.3
		 *
		 * @param environment environment variables
		 */
		public Request (Connection connection, string[] environment) {
			Object (connection: connection, environment: environment);

			var https           = Environ.get_variable (environment, "HTTPS");
			var path_translated = Environ.get_variable (environment, "PATH_TRANSLATED");
			if (https != null && https.length > 0 || path_translated != null && path_translated.has_prefix ("https://"))
				this._uri.set_scheme ("https");
			else
				this._uri.set_scheme ("http");

			this._uri.set_user (Environ.get_variable (environment, "REMOTE_USER"));
			this._uri.set_host (Environ.get_variable (environment, "SERVER_NAME"));

			var port = Environ.get_variable (environment, "SERVER_PORT");
			if (port != null)
				this._uri.set_port (int.parse (port));

			var path_info   = Environ.get_variable (environment, "PATH_INFO");
			var request_uri = Environ.get_variable (environment, "REQUEST_URI");
			if (path_info != null && path_info.length > 0)
				this._uri.set_path (path_info);
			else if (request_uri != null && request_uri.length > 0)
				this._uri.set_path (request_uri.split ("?", 2)[0]); // strip the query
			else
				this._uri.set_path ("/");

			// raw & parsed HTTP query
			var query_string = Environ.get_variable (environment, "QUERY_STRING");
			if (query_string != null && query_string.length > 0) {
				this._uri.set_query (query_string);
				this._query = Form.decode (query_string);
			} else if (path_translated != null && "?" in path_translated) {
				this._uri.set_query (path_translated.split ("?", 2)[1]);
				this._query = Form.decode (path_translated.split ("?", 2)[1]);
			} else if (request_uri != null && "?" in request_uri) {
				this._uri.set_query (request_uri.split ("?", 2)[1]);
				this._query = Form.decode (request_uri.split ("?", 2)[1]);
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
	}

	/**
	 * CGI response producing expected headers format.
	 *
	 * @since 0.3
	 */
	public class Response : VSGI.Response {

		private MessageHeaders _headers = new MessageHeaders (MessageHeadersType.RESPONSE);

		public override MessageHeaders headers { get { return this._headers; } }

		public Response (Request request) {
			Object (request: request);
		}

		/**
		 * On the first attempt to access the response body stream, the status
		 * line and headers will be written synchronously in the response
		 * stream. 'write_head_async' have to be used explicitly to perform a
		 * non-blocking operation.
		 */
		public override OutputStream body {
			get {
				try {
					// write head synchronously
					size_t bytes_written;
					write_head (out bytes_written);
				} catch (IOError err) {
					critical ("could not write the head in the connection stream: %s", err.message);
				}
				return base.body;
			}
		}

		protected override bool write_status_line (HTTPVersion  http_version,
		                                           uint         status,
		                                           string       reason_phrase,
		                                           out size_t   bytes_written,
		                                           Cancellable? cancellable = null) throws IOError {
			return request.connection.output_stream.write_all ("Status: HTTP/%s %u %s\r\n".printf (http_version == HTTPVersion.@1_0 ? "1.0" : "1.1", status, reason_phrase).data,
			                                                   out bytes_written,
			                                                   cancellable);
		}

#if GIO_2_44
		protected override async bool write_status_line_async (HTTPVersion  http_version,
		                                                       uint         status,
		                                                       string       reason_phrase,
		                                                       int          priority    = GLib.Priority.DEFAULT,
		                                                       Cancellable? cancellable = null,
		                                                       out size_t   bytes_written) throws Error {
			return yield request.connection.output_stream.write_all_async ("Status: HTTP/%s %u %s\r\n".printf (http_version == HTTPVersion.@1_0 ? "1.0" : "1.1", status, reason_phrase).data,
			                                                               priority,
			                                                               cancellable,
			                                                               out bytes_written);
		}
#endif

		protected override bool write_headers (MessageHeaders headers,
		                                       out size_t     bytes_written,
		                                       Cancellable?   cancellable = null) throws IOError {
			var head = new StringBuilder ();

			// headers
			headers.@foreach ((name, header) => {
				head.append_printf ("%s: %s\r\n", name, header);
			});

			// newline preceeding the body
			head.append ("\r\n");

			return request.connection.output_stream.write_all (head.str.data, out bytes_written, cancellable);
		}

#if GIO_2_44
		protected override async bool write_headers_async (MessageHeaders headers,
		                                                   int            priority    = GLib.Priority.DEFAULT,
		                                                   Cancellable?   cancellable = null,
		                                                   out size_t     bytes_written) throws Error {
			var head = new StringBuilder ();

			// headers
			headers.@foreach ((name, header) => {
				head.append_printf ("%s: %s\r\n", name, header);
			});

			// newline preceeding the body
			head.append ("\r\n");

			return yield request.connection.output_stream.write_all_async (head.str.data,
			                                                               priority,
			                                                               cancellable,
			                                                               out bytes_written);
		}
#endif
	}
}
