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
	var status = global::FastCGI.init ();
	if (status != 0)
		error ("code %u: failed to initialize FCGX library", status);
	return typeof (VSGI.FastCGI.Server);
}

/**
 * FastCGI implementation of VSGI.
 */
namespace VSGI.FastCGI {

	/**
	 * Produce a significant error message given an error on a
	 * {@link FastCGI.Stream}.
	 */
	private string strerror (int error) {
		if (error > 0) {
			return GLib.strerror (error);
		}
		switch (error) {
			case global::FastCGI.CALL_SEQ_ERROR:
				return "FCXG: Call seq error";
			case global::FastCGI.PARAMS_ERROR:
				return "FCGX: Params error";
			case global::FastCGI.PROTOCOL_ERROR:
				return "FCGX: Protocol error";
			case global::FastCGI.UNSUPPORTED_VERSION:
				return "FCGX: Unsupported version";
		}
		return "Unknown error code '%d'".printf (error);
	}

	private class StreamInputStream : UnixInputStream {

		public unowned global::FastCGI.Stream @in { construct; get; }

		public StreamInputStream (int fd, global::FastCGI.Stream @in) {
			Object (fd: fd, close_fd: false, @in: @in);
		}

		public override ssize_t read (uint8[] buffer, Cancellable? cancellable = null) throws IOError {
			var read = this.in.read (buffer);

			if (unlikely (read == GLib.FileStream.EOF)) {
				critical (strerror (this.in.get_error ()));
				this.in.clear_error ();
				return -1;
			}

			return read;
		}

		public override bool close (Cancellable? cancellable = null) throws IOError {
			if (unlikely (in.close () == GLib.FileStream.EOF)) {
				critical (strerror (this.in.get_error ()));
				this.in.clear_error ();
			}
			return in.is_closed;
		}
	}

	private class StreamOutputStream : UnixOutputStream {

		public unowned global::FastCGI.Stream @out { construct; get; }

		public unowned global::FastCGI.Stream err { construct; get; }

		public StreamOutputStream (int fd, global::FastCGI.Stream @out, global::FastCGI.Stream err) {
			Object (fd: fd, close_fd: false, @out: @out, err: err);
		}

		public override ssize_t write (uint8[] buffer, Cancellable? cancellable = null) throws IOError {
			var written = this.out.put_str (buffer);

			if (unlikely (written == GLib.FileStream.EOF)) {
				critical (strerror (this.out.get_error ()));
				this.out.clear_error ();
				return -1;
			}

			return written;
		}

		/**
		 * Headers are written on the first flush call.
		 */
		public override bool flush (Cancellable? cancellable = null) {
			if (unlikely (this.out.flush () == GLib.FileStream.EOF)) {
				critical (strerror (this.out.get_error ()));
				this.out.clear_error ();
				return false;
			}

			return true;
		}

		/**
		 * The 'err' stream is closed before 'out' to avoid an extra write.
		 */
		public override bool close (Cancellable? cancellable = null) throws IOError {
			if (unlikely (this.err.close () == GLib.FileStream.EOF)) {
				critical (strerror (this.err.get_error ()));
				this.err.clear_error ();
			}

			if (unlikely (this.out.close () == GLib.FileStream.EOF)) {
				critical (strerror (this.out.get_error ()));
				this.out.clear_error ();
			}

			return this.out.is_closed;
		}
	}

	private errordomain RequestError {
		FAILED
	}

	/**
	 * FastCGI Server using GLib.MainLoop.
	 */
	[Version (since = "0.1")]
	public class Server : VSGI.Server {

		[Version (since = "0.3")]
		[Description (blurb = "Listen queue depth used in the listen() call")]
		public int backlog { get; construct; default = 10; }

		private SList<Soup.URI> _uris = new SList<Soup.URI> ();

		public override SList<Soup.URI> uris {
			owned get {
				var copy_uris = new SList<Soup.URI> ();
				foreach (var uri in _uris) {
					copy_uris.append (uri.copy ());
				}
				return copy_uris;
			}
		}

		public override void listen (SocketAddress? address = null) throws GLib.Error {
			int fd;

			if (address == null) {
				fd = global::FastCGI.LISTENSOCK_FILENO;
				_uris.append (new Soup.URI ("fcgi+fd://%d/".printf (fd)));
			} else if (address is UnixSocketAddress) {
				var socket_address = address as UnixSocketAddress;

				fd = global::FastCGI.open_socket (socket_address.path, backlog);

				if (fd == -1) {
					throw new IOError.FAILED ("Could not open socket path '%s'.", socket_address.path);
				}

				_uris.append (new Soup.URI ("fcgi+unix://%s/".printf (socket_address.path)));
			} else if (address is InetSocketAddress) {
				var inet_address = address as InetSocketAddress;

				if (inet_address.get_family () == SocketFamily.IPV6) {
					throw new IOError.NOT_SUPPORTED ("The FastCGI backend does not support listening on IPv6 address.");
				}

				if (inet_address.get_address ().is_loopback) {
					throw new IOError.NOT_SUPPORTED ("The FastCGI backend cannot be restricted to the loopback interface.");
				}

				var port = inet_address.get_port () > 0 ? inet_address.get_port () : (uint16) Random.int_range (1024, 32768);

				fd = global::FastCGI.open_socket ((":%" + uint16.FORMAT).printf (port), backlog);

				if (fd == -1) {
					throw new IOError.FAILED ("Could not open TCP port '%" + uint16.FORMAT + "'.", port);
				}

				_uris.append (new Soup.URI (("fcgi://0.0.0.0:%" + uint16.FORMAT + "/").printf (port)));
			} else {
				throw new IOError.NOT_SUPPORTED ("The FastCGI backend only support listening from 'InetSocketAddress' and 'UnixSocketAddress'.");
			}

			accept_loop_async.begin (fd);
		}

		public override void listen_socket (Socket socket) {
			accept_loop_async.begin (socket.get_fd ());
		}

		public override void stop () {
			global::FastCGI.shutdown_pending ();
		}

		private async void accept_loop_async (int fd) {
			do {
				var connection = new Connection (fd);

				try {
					if (!yield connection.init_async (Priority.DEFAULT, null))
						break;
				} catch (GLib.Error err) {
					critical (err.message);
					break;
				}

				var req = new Request.from_cgi_environment (connection, connection.request.environment);
				var res = new Response (req);

				dispatch_async.begin (req, res, Priority.DEFAULT, (obj, result) => {
					try {
						dispatch_async.end (result);
					} catch (Error err) {
						critical ("%s", err.message);
					}
				});
			} while (true);
		}

		/**
		 * {@inheritDoc}
		 */
		private class Connection : IOStream, AsyncInitable {

			public int fd { construct; get; }

			public global::FastCGI.request request;

			private StreamInputStream _input_stream;
			private StreamOutputStream _output_stream;

			public override InputStream input_stream {
				get {
					return _input_stream;
				}
			}

			public override OutputStream output_stream {
				get {
					return this._output_stream;
				}
			}

			public Connection (int fd) {
				Object (fd: fd);
			}

			public async bool init_async (int priority = Priority.DEFAULT, Cancellable? cancellable = null) throws GLib.Error {
				// accept a request
				var request_status = global::FastCGI.request.init (out request, fd);

				if (request_status != 0) {
					throw new RequestError.FAILED ("could not initialize FCGX request (code %d)",
					                               request_status);
				}

				new IOChannel.unix_new (fd).add_watch_full (priority, IOCondition.IN, init_async.callback);

				yield;

				// accept loop
				IOSchedulerJob.push ((job) => {
					if (request.accept () < 0) {
						return true;
					}
					job.send_to_mainloop_async (init_async.callback);
					return false;
				}, priority, cancellable);

				yield;

				this._input_stream  = new StreamInputStream (fd, request.in);
				this._output_stream = new StreamOutputStream (fd, request.out, request.err);

				return true;
			}

			~Connection () {
				request.finish ();
				request.close (false); // keep the socket open
			}
		}
	}
}
