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
 * Stream designed to produce multipart MIME messages.
 *
 * To create a part, {@link VSGI.MultipartOutputStream.new_part} has to be
 * called. The actual part body must be written directly in the stream.
 */
[Version (since = "0.4")]
public class VSGI.MultipartOutputStream : FilterOutputStream {

	/**
	 * Boundary to separate the different parts of the message.
	 */
	[Version (since = "0.4")]
	public string boundary { construct; get; }

	/**
	 * Epilogue to be written when closing the stream.
	 */
	[Version (since = "0.4")]
	public string? epilogue { get; set; default = null; }

	[Version (since = "0.4")]
	public MultipartOutputStream (OutputStream base_stream, string boundary) {
		Object (base_stream: base_stream, boundary: boundary);
	}

	private uint8[] build_part (Soup.MessageHeaders part_headers) {
		var part = new StringBuilder ("");

		part.append_printf ("\r\n--%s\r\n", boundary);

		part_headers.foreach ((k, v) => {
			part.append_printf ("%s: %s\r\n", k, v);
		});

		part.append ("\r\n");

		return part.str.data;
	}

	/**
	 * Create a new part in this multipart message.
	 *
	 * The opening boundary and headers are written in the base stream,
	 * preparing the land for the body to be written.
	 */
	[Version (since = "0.4")]
	public bool new_part (Soup.MessageHeaders? part_headers = null) throws IOError {
		return base_stream.write_all (build_part (part_headers ?? new Soup.MessageHeaders (Soup.MessageHeadersType.MULTIPART)), null);
	}

	/**
	 * @see VSGI.MultipartOutputStream.new_part
	 */
	[Version (since = "0.4")]
	public async bool new_part_async (Soup.MessageHeaders part_headers,
	                                  int                 priority    = GLib.Priority.DEFAULT,
	                                  Cancellable?        cancellable = null) throws Error {
#if GIO_2_44
		size_t bytes_written;
		return yield base_stream.write_all_async (build_part (part_headers ?? new Soup.MessageHeaders
															  (Soup.MessageHeadersType.MULTIPART)), priority, cancellable, out bytes_written);
#else
		return new_part (part_headers);
#endif
	}

	public override ssize_t write (uint8[] buffer, Cancellable? cancellable = null) throws IOError {
		return base_stream.write (buffer, cancellable);
	}

	/**
	 * Append the final enclosing boundary and close the base stream.
	 */
	public override bool close (Cancellable? cancellable = null) throws IOError {
		return base_stream.write_all ("\r\n--%s--\r\n".printf (boundary).data, null, cancellable) &&
		       base_stream.write_all (epilogue.data, null, cancellable) &&
		       base_stream.close (cancellable);
	}
}
