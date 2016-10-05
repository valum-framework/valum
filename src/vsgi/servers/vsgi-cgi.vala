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

[ModuleInit]
public Type server_init (TypeModule type_module) {
	return typeof (VSGI.CGI.Server);
}

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

	private errordomain Error {
		FAILED
	}

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
	public class Server : VSGI.Server {

		private SList<URI> _uris = new SList<URI> ();

		public override SList<URI> uris {
			get {
				return _uris;
			}
		}

		public override OptionEntry[] get_listen_options () {
			return {};
		}

		public override void listen (Variant options) throws GLib.Error {
			if (_uris.length () > 0) {
				throw new Error.FAILED ("this server is already listening from '%s'", _uris.data.to_string (false));
			}

			_uris.append (new Soup.URI ("cgi+fd://%u/".printf (stdin.fileno ())));

			Idle.add (() => {
				var connection = new Connection (this,
				                                 new UnixInputStream (stdin.fileno (), true),
				                                 new UnixOutputStream (stdout.fileno (), true));

				var req = new Request (connection, Environ.@get ());
				var res = new Response (req);

				// handle a single request and quit
				try {
					dispatch (req, res);
				} catch (GLib.Error err) {
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
