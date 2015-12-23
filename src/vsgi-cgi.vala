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
 * @since 0.2
 */
[CCode (gir_namespace = "VSGI.CGI", gir_version = "0.2")]
namespace VSGI.CGI {

	public class Request : VSGI.Request {

		/**
		 * CGI environment variables encoded in 'NAME=VALUE'.
		 *
		 * @since 0.2
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
		 * @since 0.2
		 *
		 * @param environment environment variables
		 */
		public Request (IOStream connection, string[] environment) {
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

			var request_uri = Environ.get_variable (environment, "REQUEST_URI");
			var path_info   = Environ.get_variable (environment, "PATH_INFO");
			if (request_uri != null && request_uri.length > 0)
				this._uri.set_path (request_uri.split ("?", 2)[0]); // strip the query
			else if (path_info != null && path_info.length > 0)
				this._uri.set_path (path_info);
			else
				this._uri.set_path ("/");

			// raw HTTP query
			this._uri.set_query (Environ.get_variable (environment, "QUERY_STRING"));

			// parsed HTTP query
			var query_string = Environ.get_variable (environment, "QUERY_STRING");
			if (query_string != null)
				this._query = Form.decode (query_string);

			// extract HTTP headers, they are prefixed by 'HTTP_' in environment variables
			foreach (var variable in environment) {
				var parts = variable.split ("=", 2);
				if (parts[0].has_prefix ("HTTP_")) {
					this.headers.append (parts[0].substring (5).replace ("_", "-").casefold (), parts[1]);
				}
			}
		}
	}

	public class Response : VSGI.Response {

		private MessageHeaders _headers = new MessageHeaders (MessageHeadersType.RESPONSE);

		public override MessageHeaders headers { get { return this._headers; } }

		public Response (Request request) {
			Object (request: request);
		}

		/**
		 * {@inheritDoc}
		 *
		 * CGI protocols does not have a status line. They use the 'Status'
		 * header instead.
		 */
		protected override uint8[]? build_head () {
			var head = new StringBuilder ();

			head.append_printf ("Status: %u %s\r\n", status, global::Soup.Status.get_phrase (status));

			this.headers.foreach ((k, v) => {
				head.append_printf ("%s: %s\r\n", k, v);
			});

			// newline preceeding the body
			head.append ("\r\n");

			return head.str.data;
		}
	}

	/**
	 * {@inheritDoc}
	 *
	 * Unlike other VSGI implementations, which are actively awaiting upon
	 * requests, CGI handles a single request and then wait until the underlying
	 * {@link GLib.Application} quits. Longstanding operations can invoke
	 * {@link GLib.Application.hold} and {@link GLib.Application.release} to
	 * keep the server alive as long as necessary.
	 */
	public class Server : VSGI.Server {

		public Server (string application_id, owned VSGI.ApplicationCallback application) {
			base (application_id, (owned) application);
		}

		public override int command_line (ApplicationCommandLine command_line) {
			var connection = new Connection (this,
#if GIO_2_34
			                                 command_line.get_stdin (),
#else
			                                 new UnixInputStream (stdin.fileno (), true),
#endif
			                                 new UnixOutputStream (stdout.fileno (), true));

			var req = new Request (connection, command_line.get_environ ());
			var res = new Response (req);

			// handle a single request and quit
			this.handle (req, res);

			return 0;
		}

		private class Connection : IOStream {

			private InputStream _input_stream;
			private OutputStream _output_stream;

			public Server server { construct; get; }

			public override InputStream input_stream { get { return this._input_stream; } }

			public override OutputStream output_stream { get { return this._output_stream; } }

			public Connection (Server server, InputStream input_stream, OutputStream output_stream) {
				Object (server: server);
				this._input_stream  = input_stream;
				this._output_stream = output_stream;
				this.server.hold ();
			}

			~Connection () {
				this.server.release ();
			}
		}
	}
}
