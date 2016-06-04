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
	return typeof (VSGI.FastCGI.Server);
}

/**
 * FastCGI implementation of VSGI.
 *
 * @since 0.1
 */
[CCode (gir_namespace = "VSGI.FastCGI", gir_version = "0.2")]
namespace VSGI.FastCGI {

	private errordomain FastCGIError {
		FAILED
	}

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

			if (read == GLib.FileStream.EOF) {
				warning (strerror (this.in.get_error ()));
				this.in.clear_error ();
				return -1;
			}

			return read;
		}

		public override bool close (Cancellable? cancellable = null) throws IOError {
			if (in.close () == GLib.FileStream.EOF) {
				warning (strerror (this.in.get_error ()));
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

			if (written == GLib.FileStream.EOF) {
				warning (strerror (this.out.get_error ()));
				this.out.clear_error ();
				return -1;
			}

			return written;
		}

		/**
		 * Headers are written on the first flush call.
		 */
		public override bool flush (Cancellable? cancellable = null) {
			return this.err.flush () && this.out.flush ();
		}

		/**
		 * The 'err' stream is closed before 'out' to avoid an extra write.
		 */
		public override bool close (Cancellable? cancellable = null) throws IOError {
			if (this.err.close () == GLib.FileStream.EOF) {
				warning (strerror (this.err.get_error ()));
				this.err.clear_error ();
			}

			if (this.out.close () == GLib.FileStream.EOF) {
				warning (strerror (this.out.get_error ()));
				this.out.clear_error ();
			}

			return this.err.is_closed && this.out.is_closed;
		}
	}

	/**
	 * {@inheritDoc}
	 */
	public class Request : CGI.Request {

		/**
		 * {@inheritDoc}
		 *
		 * Initialize FastCGI-specific environment variables.
		 */
		public Request (IOStream connection, string[] environment) {
			base (connection, environment);
		}
	}

	/**
	 * FastCGI Response
	 */
	public class Response : CGI.Response {

		/**
		 * {@inheritDoc}
		 */
		public Response (Request req) {
			base (req);
		}
	}

	/**
	 * @since 0.3
	 */
	private errordomain RequestError {
		FAILED
	}

	/**
	 * FastCGI Server using GLib.MainLoop.
	 *
	 * @since 0.1
	 */
	public class Server : VSGI.Server {

		private SList<Soup.URI> _uris = new SList<Soup.URI> ();

		public override unowned SList<Soup.URI> uris {
			get { return _uris; }
		}

		construct {
#if GIO_2_40
			const OptionEntry[] options = {
				{"socket",          's', 0, OptionArg.FILENAME, null, "Listen to the provided UNIX domain socket (or named pipe for WinNT)"},
				{"port",            'p', 0, OptionArg.INT,      null, "Listen to the provided TCP port"},
				{"file-descriptor", 'f', 0, OptionArg.INT,      null, "Listen to the provided file descriptor",       "0"},
				{"backlog",         'b', 0, OptionArg.INT,      null, "Listen queue depth used in the listen() call", "10"},
				{null}
			};
			this.add_main_option_entries (options);
#endif

			this.startup.connect (() => {
				var status = global::FastCGI.init ();
				if (status != 0)
					error ("code %u: failed to initialize FCGX library", status);
			});

			this.shutdown.connect (global::FastCGI.shutdown_pending);
		}

		public override void listen (Variant options) throws Error {
			var backlog = options.lookup_value ("backlog", VariantType.INT32) ?? new Variant.@int32 (10);

			var fd = global::FastCGI.LISTENSOCK_FILENO;

			if (options.lookup_value ("socket", VariantType.BYTESTRING) != null) {
				var socket_path = options.lookup_value ("socket", VariantType.BYTESTRING).get_bytestring ();

				fd = global::FastCGI.open_socket (socket_path, backlog.get_int32 ());

				if (fd == -1) {
					throw new FastCGIError.FAILED ("could not open socket path %s", socket_path);
				}

				_uris.append (new Soup.URI ("fcgi+unix://%s/".printf (socket_path)));
			}

			else if (options.lookup_value ("port", VariantType.INT32) != null) {
				var port =  (options.lookup_value ("port", VariantType.INT32).get_int32 ());

				fd = global::FastCGI.open_socket (":%d".printf (port), backlog.get_int32 ());

				if (fd == -1) {
					throw new FastCGIError.FAILED ("could not open TCP port '%d'", port);
				}

				_uris.append (new Soup.URI ("fcgi://0.0.0.0:%d/".printf (port)));
			}

			else if (options.lookup_value ("file-descriptor", VariantType.INT32) != null) {
				fd = options.lookup_value ("file-descriptor", VariantType.INT32).get_int32 ();
				_uris.append (new Soup.URI ("fcgi+fd://%u/".printf (fd)));
			}

			else {
				_uris.append (new Soup.URI ("fcgi+fd://%u/".printf (global::FastCGI.LISTENSOCK_FILENO)));
			}

			accept_loop_async.begin (fd, (obj, result) => {
				accept_loop_async.end (result);
				release ();
			});
		}

		private async void accept_loop_async (int fd) {
			do {
				var connection = new Connection (fd);

				try {
					if (!yield connection.init_async (Priority.DEFAULT, null))
						break;
				} catch (Error err) {
					critical (err.message);
					break;
				}

				var req = new Request (connection, connection.request.environment);
				var res = new Response (req);

				try {
					dispatch (req, res);
				} catch (Error err) {
					critical (err.message);
				}
			} while (true);
		}

		/**
		 * {@inheritDoc}
		 */
		private class Connection : IOStream, AsyncInitable {

			/**
			 * @since 0.2
			 */
			public int fd { construct; get; }

			/**
			 * @since 0.3
			 */
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

			/**
			 * @since 0.2
			 */
			public Connection (int fd) {
				Object (fd: fd);
			}

			/**
			 * @since 0.3
			 */
			public async bool init_async (int priority = Priority.DEFAULT, Cancellable? cancellable = null) throws Error {
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
