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

/**
 * Mock implementation of VSGI used for testing purposes.
 */
namespace VSGI.Mock {

	/**
	 * Stubbed connection with in-memory streams.
	 *
	 * The typical use case is to create a {@link VSGI.Mock.Request} with a
	 * stubbed connection so that the produced and consumed messages can be
	 * easily inspected.
	 */
	[Version (experimental = true)]
	public class Connection : VSGI.Connection {

		private MemoryInputStream _memory_input_stream   = new MemoryInputStream ();
		private MemoryOutputStream _memory_output_stream = new MemoryOutputStream (null, realloc, free);

		public override InputStream input_stream { get { return _memory_input_stream; } }

		public override OutputStream output_stream { get { return _memory_output_stream; } }

		[Version (experimental = true)]
		public Connection (Server server) {
			Object (server: server);
		}

		[Version (experimental = true)]
		public MemoryInputStream get_memory_input_stream ()
		{
			return _memory_input_stream;
		}

		[Version (experimental = true)]
		public MemoryOutputStream get_memory_output_stream () {
			return _memory_output_stream;
		}
	}

	/**
	 * Test implementation of Request used to stub a request.
	 */
	[Version (experimental = true)]
	public class Request : VSGI.Request {

		private Soup.HTTPVersion _http_version    = Soup.HTTPVersion.@1_1;
		private string _method                    = VSGI.Request.GET;
		private Soup.URI _uri                     = new Soup.URI (null);
		private HashTable<string, string>? _query = null;

		public override Soup.HTTPVersion http_version { get { return this._http_version; } }

		public override string gateway_interface { owned get { return "Mock/0.3"; } }

		public override string method { owned get { return this._method; } }

		public override Soup.URI uri { get { return this._uri; } }

		public override HashTable<string, string>? query { get { return this._query; } }

		[Version (experimental = true)]
		public Request (Connection connection, string method, Soup.URI uri, HashTable<string, string>? query = null) {
			Object (connection: connection, headers: new Soup.MessageHeaders (Soup.MessageHeadersType.REQUEST));
			this._method = method;
			this._uri    = uri;
			this._query  = query;
		}

		[Version (experimental = true)]
		public Request.with_method (string method, Soup.URI uri, HashTable<string, string>? query = null) {
			this (new Connection (new Server ()), method, uri, query);
		}

		[Version (experimental = true)]
		public Request.with_uri (Soup.URI uri, HashTable<string, string>? query = null) {
			this (new Connection (new Server ()), "GET", uri, query);
		}

		[Version (experimental = true)]
		public Request.with_query (HashTable<string, string>? query) {
			this (new Connection (new Server ()), "GET", new Soup.URI ("http://localhost/"), query);
		}
	}

	/**
	 * Test implementation of VSGI.Response to stub a response.
	 */
	[Version (experimental = true)]
	public class Response : VSGI.Response {

		[Version (experimental = true)]
		public Response (Request req) {
			Object (request: req, headers: new Soup.MessageHeaders (Soup.MessageHeadersType.RESPONSE));
		}

		[Version (experimental = true)]
		public Response.with_status (Request req, uint status) {
			Object (request: req, status: status, headers: new Soup.MessageHeaders (Soup.MessageHeadersType.RESPONSE));
		}

		protected override bool write_status_line (Soup.HTTPVersion http_version, uint status, string reason_phrase, out size_t bytes_written, Cancellable? cancellable = null)  throws IOError {
			return request.connection.output_stream.write_all ("HTTP/%s %u %s\r\n".printf (http_version == Soup.HTTPVersion.@1_0 ? "1.0" : "1.1", status, reason_phrase).data,
			                                                   out bytes_written,
			                                                   cancellable);
		}

		protected override bool write_headers (Soup.MessageHeaders headers, out size_t bytes_written, Cancellable?
				cancellable = null) throws IOError {
			var head = new StringBuilder ();

			// headers
			headers.@foreach ((name, header) => {
				head.append_printf ("%s: %s\r\n", name, header);
			});

			// newline preceeding the body
			head.append ("\r\n");

			return request.connection.output_stream.write_all (head.str.data, out bytes_written, cancellable);
		}
	}

	[Version (experimental = true)]
	public class Server : VSGI.Server {

		public override SList<Soup.URI> uris { owned get { return new SList<Soup.URI> (); } }

		public override void listen (SocketAddress? address = null) throws Error {
			// nothing to listen on
		}

		public override void listen_socket (Socket socket) throws Error {
			// nothing to listen on
		}

		public override void stop () {
			// nothing to stop
		}
	}
}
