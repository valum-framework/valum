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
using FastCGI;
using Soup;

/**
 * FastCGI implementation of VSGI.
 *
 * @since 0.1
 */
[CCode (gir_namespace = "VSGI.FastCGI", gir_version = "0.2")]
namespace VSGI.FastCGI {

	/**
	 * Process the error on the stream.
	 */
	private inline void process_error (global::FastCGI.Stream stream) throws IOError {
		var error = new GLib.Error (IOError.quark (),
		                            FileUtils.error_from_errno (stream.get_error ()), // TODO: fix and use IOError.from_errno
		                            strerror (stream.get_error ()));

		// FastCGI error
		if (stream.get_error () < 0) {
			switch (stream.get_error ()) {
				case global::FastCGI.CALL_SEQ_ERROR:
					error.message = "FCXG: Call seq error";
					break;
				case global::FastCGI.PARAMS_ERROR:
					error.message = "FCGX: Params error";
					break;
				case global::FastCGI.PROTOCOL_ERROR:
					error.message = "FCGX: Protocol error";
					break;
				case global::FastCGI.UNSUPPORTED_VERSION:
					error.message = "FCGX: Unsupported version";
					break;
			}
		}

		stream.clear_error ();

		throw (IOError) error;
	}

	private class StreamInputStream : InputStream, PollableInputStream {

		public GLib.Socket socket { construct; get; }

		public unowned global::FastCGI.Stream @in { construct; get; }

		public StreamInputStream (GLib.Socket socket, global::FastCGI.Stream @in) {
			Object (socket: socket, @in: @in);
		}

		public override ssize_t read (uint8[] buffer, Cancellable? cancellable = null) throws IOError {
			var read = this.in.read (buffer);

			if (read == GLib.FileStream.EOF) {
				process_error (this.in);
			}

			return read;
		}

		public override bool close (Cancellable? cancellable = null) throws IOError {
			if (this.in.close () == GLib.FileStream.EOF) {
				process_error (this.in);
			}

			return this.in.is_closed;
		}

		public bool can_poll () {
			return true; // hope so!
		}

		public PollableSource create_source (Cancellable? cancellable = null) {
			var source = new PollableSource (this);
			source.add_child_source (this.socket.create_source (IOCondition.IN, cancellable));
			return source;
		}

		public bool is_readable () {
			return true;
		}

		public ssize_t read_nonblocking_fn (uint8[] buffer) throws Error {
			var read = this.in.read (buffer);

			if (read == GLib.FileStream.EOF) {
				process_error (this.in);
			}

			return read;
		}
	}

	private class StreamOutputStream : OutputStream, PollableOutputStream {

		public GLib.Socket socket { construct; get; }

		public unowned global::FastCGI.Stream @out { construct; get; }

		public unowned global::FastCGI.Stream err { construct; get; }

		/**
		 * @param socket socket used to obtain {@link GLib.SocketSource}
		 */
		public StreamOutputStream (GLib.Socket socket, global::FastCGI.Stream @out, global::FastCGI.Stream err) {
			Object (socket: socket, @out: @out, err: err);
		}

		public override ssize_t write (uint8[] buffer, Cancellable? cancellable = null) throws IOError {
			var written = this.out.put_str (buffer);

			if (written == GLib.FileStream.EOF) {
				process_error (this.out);
			}

			return written;
		}

		/**
		 * Headers are written on the first flush call.
		 */
		public override bool flush (Cancellable? cancellable = null) {
			return this.out.flush ();
		}

		public override bool close (Cancellable? cancellable = null) throws IOError {
			if (this.err.close () == GLib.FileStream.EOF) {
				process_error (this.err);
			}

			if (this.out.close () == GLib.FileStream.EOF) {
				process_error (this.out);
			}

			return this.err.is_closed && this.out.is_closed;
		}

		public bool can_poll () {
			return true; // hope so!
		}

		public PollableSource create_source (Cancellable? cancellable = null) {
			var source = new PollableSource (this);
			source.add_child_source (this.socket.create_source (IOCondition.OUT, cancellable));
			return source;
		}

		public bool is_writable () {
			return true;
		}

		public ssize_t write_nonblocking (uint8[] buffer) throws Error {
			var written = this.out.put_str (buffer);

			if (written == GLib.FileStream.EOF) {
				process_error (this.out);
			}

			return written;
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
		public Request (IOStream connection, HashTable<string, string> environment) {
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
	 * FastCGI Server using GLib.MainLoop.
	 *
	 * @since 0.1
	 */
	public class Server : VSGI.Server {

		/**
		 * FastCGI socket file descriptor.
		 */
		public GLib.Socket? socket { get; protected set; default = null; }

		/**
		 * {@inheritDoc}
		 */
		public Server (string application_id, owned ApplicationCallback application) {
			base (application_id, (owned) application);

#if GIO_2_40
			const OptionEntry[] options = {
				{"socket",          's', 0, OptionArg.FILENAME, null, "path to the UNIX socket"},
				{"port",            'p', 0, OptionArg.INT,      null, "TCP port on this host"},
				{"file-descriptor", 'f', 0, OptionArg.INT,      null, "file descriptor", "0"},
				{"backlog",         'b', 0, OptionArg.INT,      null, "listen queue depth used in the listen() call", "0"},
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

		public override int command_line (ApplicationCommandLine command_line) {
#if GIO_2_40
			var options = command_line.get_options_dict ();

			if ((options.contains ("socket") && options.contains ("port")) ||
			    (options.contains ("socket") && options.contains ("file-descriptor")) ||
			    (options.contains ("port") && options.contains ("file-descriptor"))) {
				command_line.printerr ("--socket, --port and --file-descriptor must not be specified simultaneously\n");
				return 1;
			}

			var backlog = options.contains ("backlog") ? options.lookup_value ("backlog", VariantType.INT32).get_int32 () : 0;
#endif

			try {
#if GIO_2_40
				if (options.contains ("socket")) {
					var socket_path = options.lookup_value ("socket", VariantType.BYTESTRING).get_bytestring ();
					this.socket     = new GLib.Socket.from_fd (open_socket (socket_path, backlog));

					if (!this.socket.is_connected ()) {
						command_line.printerr ("could not open socket path %s\n", socket_path);
						return 1;
					}

					command_line.print ("listening on %s (backlog %d)\n", socket_path, backlog);
				}

				else if (options.contains ("port")) {
					var port    = ":%d".printf(options.lookup_value ("port", VariantType.INT32).get_int32 ());
					this.socket = new GLib.Socket.from_fd (open_socket (port, backlog));

					if (!this.socket.is_connected ()) {
						command_line.printerr ("could not open TCP socket at port %s\n", port);
						return 1;
					}

					command_line.print ("listening on tcp://0.0.0.0:%s (backlog %d)\n", port, backlog);
				}

				else if (options.contains ("file-descriptor")) {
					var file_descriptor = options.lookup_value ("file-descriptor", VariantType.INT32).get_int32 ();
					this.socket         = new GLib.Socket.from_fd (file_descriptor);

					if (!this.socket.is_connected ()) {
						command_line.printerr ("could not open file descriptor %d\n", file_descriptor);
						return 1;
					}

					command_line.print ("listening on the file descriptor %d\n", file_descriptor);
				}

				else
#endif
				{
					this.socket = new GLib.Socket.from_fd (0);
					command_line.print ("listening the default socket\n");
				}
			} catch (Error err) {
				command_line.printerr ("%s\n", err.message);
				return 1;
			}

			var source = socket.create_source (IOCondition.IN);

			source.set_callback (() => {
				global::FastCGI.request request;

				// accept a request
				var request_status = global::FastCGI.request.init (out request, socket.fd);

				if (request_status != 0) {
					command_line.printerr ("code %u: could not initialize FCGX request\n", request_status);
					return false;
				}

				var status = request.accept ();

				if (status < 0) {
					request.close ();
					command_line.printerr ("request %u: cannot not accept anymore request (status %u)\n",
					                       request.request_id,
					                       status);
					return false;
				}

				var environment = new HashTable<string, string> (str_hash, str_equal);

				foreach (var e in request.environment.get_all ()) {
					var parts = e.split ("=", 2);
					environment[parts[0]] = parts.length == 2 ? parts[1] : "";
				}

				var connection = new Connection (this, request);

				var req = new Request (connection, environment);
				var res = new Response (req);

				this.handle (req, res);

				debug ("%s: %u %s %s", this.get_application_id (), res.status, req.method, req.uri.get_path ());

				return true;
			});

			source.attach (MainContext.default ());

			// keep the process alive
			this.hold ();

			return 0;
		}

		/**
		 * {@inheritDoc}
		 */
		private class Connection : IOStream {

			public Server server { construct; get; }

			private unowned global::FastCGI.request request;
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

			public Connection (Server server, global::FastCGI.request request) {
				Object (server: server);
				this.request        = request;
				this._input_stream  = new StreamInputStream (server.socket, request.in);
				this._output_stream = new StreamOutputStream (server.socket, request.out, request.err);
			}

			~Connection () {
				request.finish ();
				request.close (false); // keep the socket open
			}
		}
	}
}
