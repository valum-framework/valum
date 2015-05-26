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
		 * Response cookies.
		 *
		 * If set, the 'Set-Cookie' headers will be removed and replaced by
		 * the new values.
		 *
		 * @since 0.1
		 */
		public SList<Cookie> cookies {
			set {
				this.headers.remove ("Set-Cookie");

				foreach (var cookie in value) {
					this.headers.append ("Set-Cookie", cookie.to_set_cookie_header ());
				}
			}
		}

		/**
		 * Response raw body.
		 *
		 * @since 0.2
		 */
		public OutputStream raw_body { construct; protected get; }

		/**
		 * Response body.
		 *
		 * On the first attempt to access the response body stream, the status
		 * line and headers will be written in the response stream. Subsequent
		 * accesses will remain the stream untouched.
		 *
		 * The provided stream is safe for transfer encoding and will filter
		 * the stream properly if it's chunked.
		 *
		 * @since 0.2
		 */
		public virtual OutputStream body {
			get {
				if (this.headers_written)
					return this.raw_body;

				if (!this.status_line_written) {
					this.write_status_line ();
					this.status_line_written = true;
				}

				if (!this.headers_written) {
					this.write_headers ();
					this.headers_written = true;
				}

				return this.raw_body;
			}
		}

		/**
		 * @since 0.2
		 */
		protected bool status_line_written = false;

		/**
		 * Write the HTTP status line in the response raw body.
		 *
		 * It is invoked once when the body is accessed for the first time.
		 * This must be invoked before any headers writing operations,
		 * preferably with the response status property and protocol
		 * version.
		 *
		 * @since 0.2
		 *
		 * @param status   response status code
		 * @param protocol HTTP protocol and version, eg. HTTP/1.1
		 */
		protected virtual ssize_t write_status_line () throws IOError {
			var status_line = "%s %u %s\r\n".printf ("HTTP/1.1", status, Status.get_phrase (status));
			return this.raw_body.write (status_line.data);
		}

		/**
		 * @since 0.2
		 */
		protected bool headers_written = false;

		/**
		 * Write the headers in the response raw body.
		 *
		 * It is invoked once before the body is written and can be invoked
		 * later to produce multipart messages.
		 *
		 * @since 0.2
		 *
		 * @param headers headers to write in the response stream
		 */
		protected virtual ssize_t write_headers () throws IOError {
			ssize_t written = 0;

			// headers
			this.headers.foreach ((k, v) => {
				written += this.raw_body.write ("%s: %s\r\n".printf (k, v).data);
			});

			// newline preceeding the body
			written += this.raw_body.write ("\r\n".data);

			return written;
		}

		/**
		 * End the {@link Response} processing and notify that event to the
		 * listeners.
		 *
		 * The default handler will write the status line, write the response
		 * headers and close the body if any of these is not already done.
		 *
		 * @since 0.2
		 */
		public virtual signal void end () {
			if (!this.status_line_written) {
				this.write_status_line ();
				this.status_line_written = true;
			}

			if (!this.headers_written) {
				this.write_headers ();
				this.headers_written = true;
			}
		}
	}

	/**
	 * Provide chunking capability to a stream.
	 *
	 * @since 0.2
	 */
	public class ChunkedOutputStream : FilterOutputStream {

		public ChunkedOutputStream (OutputStream base_stream) {
			Object (base_stream: base_stream);
		}

		/**
		 * {@inheritdoc}
		 *
		 * Writing has an expansion factor of ceil(log_16(data.length)) + 4
		 * due to the presence of newlines and predicted size of a chunk.
		 */
		public override ssize_t write (uint8[] data, Cancellable? cancellable = null) throws IOError {
			ssize_t written = 0;

			// write the size
			written += this.base_stream.write ("%X\r\n".printf (data.length).data, cancellable);

			// write the chunk
			written += this.base_stream.write (data, cancellable);

			// terminate the chunk
			written += this.base_stream.write ("\r\n".data, cancellable);

			return written;
		}

		/**
		 * {@inheritDoc}
		 *
		 * Closing the stream will write 5 bytes to end the chunking properly.
		 *
		 * @since 0.2
		 */
		public override bool close (Cancellable? cancellable = null) throws IOError {
			this.base_stream.write ("0\r\n".data, cancellable);
			this.base_stream.write ("\r\n".data, cancellable);

			return this.base_stream.close (cancellable);
		}
	}
}
