using GLib;
using Soup;

namespace VSGI {
	/**
	 * Response representing a request resource.
	 *
	 * @since 0.0.1
	 */
	public abstract class Response : Object {

		/**
		 * Request to which this response is responding.
		 *
		 * @since 0.1
		 */
		public Request request { construct; get; }

		/**
		 * Response status.
		 *
		 * @since 0.0.1
		 */
		public abstract uint status { get; set; }

		/**
		 * Response headers.
		 *
		 * @since 0.0.1
		 */
		public abstract MessageHeaders headers { get; }

		/**
		 * Tells if the head has been written in the connection
		 * {@link GLib.OutputStream}.
		 *
		 * @since 0.2
		 */
		public bool head_written { get; protected set; default = false; }

		/**
		 * Response body.
		 *
		 * On the first attempt to access the response body stream, the status
		 * line and headers will be written synchronously in the response
		 * stream. {@link VSGI.Response.write_head_async} have to be used
		 * explicitly to perform a non-blocking operation.
		 *
		 * The provided stream is safe for transfer encoding and will filter
		 * the stream properly if it's chunked.
		 *
		 * Apply filters on the base_stream to make it usable
		 *
		 * Typically, this would involve appling chunked encoding, buffering,
		 * transparent compression and other kind of filters required by the
		 * implementation.
		 *
		 * For CGI-ish protocols, the server will generally deal with transfer
		 * encoding automatically, so the default implementation is to simply
		 * return the base_stream.
		 *
		 * @since 0.2
		 */
		public virtual OutputStream body {
			get {
				try {
					// write head synchronously
					if (!this.head_written)
						this.write_head ();
				} catch (IOError err) {
					warning ("could not write the head in the connection stream");
				}

				return this.request.connection.output_stream;
			}
		}

		/**
		 * Produce the head of this response including the status line, the
		 * headers and the newline preceeding the body as it would be written in
		 * the base stream.
		 *
		 * The default implementation will produce a valid HTTP/1.1 head
		 * including the status line and headers.
		 *
		 * @since 0.2
		 */
		protected virtual uint8[]? build_head () {
			var head = new StringBuilder ();

			// status line
			head.append ("%s %u %s\r\n".printf (this.request.http_version == HTTPVersion.@1_0 ? "HTTP/1.0" : "HTTP/1.1",
						status,
						Status.get_phrase (status)));

			// headers
			this.headers.foreach ((k, v) => {
				head.append ("%s: %s\r\n".printf (k, v));
			});

			// newline preceeding the body
			head.append ("\r\n");

			return head.str.data;
		}

		/**
		 * Write status line and headers into the base stream.
		 *
		 * This is invoked automatically when accessing the response body for
		 * the first time.
		 *
		 * @since 0.2
		 *
		 * @return the status line and headers data or null if nothing should be
		 *         written in the output stream.
		 */
		public bool write_head (Cancellable? cancellable = null) throws IOError
			requires (!this.head_written)
			ensures  (this.head_written)
		{
			var head = this.build_head ();

			if (head == null) {
				this.head_written = true;
			} else {
				size_t bytes_written;
				this.head_written = this.request.connection.output_stream.write_all (head,
				                                                                     out bytes_written,
				                                                                     cancellable);
			}

			return this.head_written;
		}

#if GIO_2_44
		/**
		 * Write status line and headers asynchronously.
		 *
		 * @since 0.2
		 */
		public async bool write_head_async (int priority = GLib.Priority.DEFAULT, Cancellable? cancellable = null) throws Error
			requires (!this.head_written)
			ensures  (this.head_written)
		{
			var head = this.build_head ();

			if (head == null) {
				this.head_written = true;
			} else {
				size_t bytes_written;
				this.head_written = yield this.request.connection.output_stream.write_all_async (head,
																								 priority,
																								 cancellable,
																								 out bytes_written);
			}

			return this.head_written;
		}
#endif
	}
}
