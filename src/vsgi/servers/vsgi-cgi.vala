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

[ModuleInit]
public Type server_init (TypeModule type_module) {
	return typeof (VSGI.CGI.Server);
}

/**
 * CGI implementation of VSGI.
 *
 * This implementation is sufficiently general to implement other CGI-like
 * protocol such as FastCGI and SCGI.
 */
namespace VSGI.CGI {

	private class Connection : VSGI.Connection {

		private InputStream _input_stream;
		private OutputStream _output_stream;

		public override InputStream input_stream { get { return this._input_stream; } }

		public override OutputStream output_stream { get { return this._output_stream; } }

		public Connection (Server server, InputStream input_stream, OutputStream output_stream) {
			Object (server: server);
			this._input_stream  = input_stream;
			this._output_stream = output_stream;
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
	[Version (since = "0.1")]
	public class Server : VSGI.Server {

		public override SList<Soup.URI> uris {
			owned get {
				return new SList<Soup.URI> ();
			}
		}

		public override void listen (SocketAddress? address = null) throws Error {
			if (address != null) {
				throw new IOError.NOT_SUPPORTED ("The CGI server only support listening from standard streams.");
			}

			Idle.add (() => {
				var connection = new Connection (this,
				                                 new UnixInputStream (stdin.fileno (), true),
				                                 new UnixOutputStream (stdout.fileno (), true));

				var req = new Request (connection, Environ.@get ());
				var res = new Response (req);

				// handle a single request and quit
				try {
					dispatch (req, res);
				} catch (Error err) {
					critical (err.message);
				}

				return false;
			});

			Idle.add (() => {
				if (MainContext.@default ().pending ()) {
					return true;
				} else {
					Process.exit (0);
				}
			});
		}

		public override void listen_socket (Socket socket) throws Error {
			throw new IOError.NOT_SUPPORTED ("The CGI server only support listening from standard streams.");
		}

		public override void stop () {
			// CGI handle a single connection
		}

		/**
		 * Forking does not make sense for CGI.
		 */
		public override Pid fork () {
			return 0;
		}
	}
}
