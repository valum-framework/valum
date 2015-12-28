using GLib;
using Soup;

namespace VSGI {

	/**
	 * Buffers the body of a response.

	 * Unlike the traditional {@link VSGI.Response}, the head is not written
	 * when the body is accessed, but instead flushed. Modifications to the
	 * status line and headers can still occur even if content has been written
	 * to the body stream.

	 * The default size of the buffer is set to the value of the 'Content-Length'
	 * header or defaults to 4 kilobytes if it hasn't been set.
	 *
	 * If the 'Content-Length' header is set in the response
	 * The default size of the buffer is
	 *
	 * @since 0.3
	 */
	public class BufferedResponse : FilteredResponse {

		public BufferedOutputStream buffer { construct; get; }

		public override OutputStream body {
			get {
				return this.buffer;
			}
		}

		/**
		 *
		 *
		 * @since 0.3
		 */
		public BufferedResponse (Response base_response) {
			base_response.head_written = true; // trick the response into
			var buffer = base_response.headers.get_encoding () == Encoding.CONTENT_LENGTH ?
				new BufferedOutputStream.sized (base_response.body, (size_t) base_response.headers.get_content_length ()) :
				new BufferedOutputStream (base_response.body);
			Object (base_response: base_response, buffer: buffer);
		}

		public BufferedResponse.sized (Response base_response, uint buffer_size) {
			base_response.head_written = true; // trick the response into
			Object (base_response: base_response, buffer: new BufferedOutputStream.sized (base_response.body, buffer_size));
		}
	}
}
