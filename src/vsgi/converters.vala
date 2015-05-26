using GLib;

namespace VSGI {
	/**
	 * Chunks data according to RFC2616 section 3.6.1.
	 *
	 * [http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.6.1]
	 *
	 * This process has an expansion factor of ceil (log_16 (size)) + 4 due to
	 * the presence of predicted size and newlines.
	 *
	 * The process will always try to convert as much data as possible, chunking
	 * a single bloc per convert call.
	 *
	 * @since 0.2
	 */
	public class ChunkedConverter : Object, Converter {

		public ConverterResult convert (uint8[] inbuf,
				                        uint8[] outbuf,
										ConverterFlags flags,
										out size_t bytes_read,
										out size_t bytes_written) throws IOError {
			size_t required_size = 0;
			var size_buffer      = inbuf.length.to_string ("%X");

			// chunk size and newline
			required_size += size_buffer.length + "\r\n".length;

			// chunk and newline
			required_size += inbuf.length + "\r\n".length;

			if (required_size > outbuf.length)
				throw new IOError.NO_SPACE ("need %u more bytes to write the chunk", (uint) (required_size - outbuf.length));

			bytes_written = 0;

			// size
			for (int i = 0; i < size_buffer.length; i++)
				outbuf[bytes_written++] = size_buffer[i];

			// newline after the size
			outbuf[bytes_written++] = '\r';
			outbuf[bytes_written++] = '\n';

			// chunk
			for (int i = 0; i < inbuf.length; i++)
				outbuf[bytes_written++] = inbuf[i];

			// chunk is fully read
			bytes_read = inbuf.length;

			// newline after the chunk
			outbuf[bytes_written++] = '\r';
			outbuf[bytes_written++] = '\n';

			// end of chunked data, but the zero-chunk has already been written
			if (ConverterFlags.INPUT_AT_END in flags) {
				return ConverterResult.FINISHED;
			}

			return ConverterResult.CONVERTED;
		}

		public void reset () {
			// no internal state
		}
	}
}
