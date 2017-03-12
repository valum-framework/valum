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

#if HAVE_MEMMEM
private extern void* memmem (uint8[] haystack, uint8[] needle);
#else
private void* memmem (uint8[] haystack, uint8[] needle) {
	for (var i = 0; i < haystack.length - needle.length; i++) {
		if (Memory.cmp (haystack[i:needle.length], needle, needle.length) == 0) {
			return &haystack[i];
		}
	}
	return null;
}
#endif

/**
 * Multipart input stream conforming to RFC 1341.
 */
public class VSGI.MultipartInputStream : FilterInputStream {

	private DataInputStream data_base_stream;

	[Version (since = "0.4")]
	public string boundary { construct; get; }

	[Version (since = "0.4")]
	public MultipartInputStream (InputStream base_stream, string boundary) {
		Object (base_stream: base_stream, boundary: boundary);
	}

	[Version (since = "0.4")]
	public MultipartInputStream.from_request (Request req) {
		HashTable<string, string> @params;
		req.headers.get_content_type (out @params);
		this (req.body, @params["boundary"]);
	}

	construct {
		data_base_stream = new DataInputStream (base_stream);
		data_base_stream.set_newline_type (DataStreamNewlineType.CR_LF);
	}

	/**
	 * Position the stream on the next part of the message, skipping content
	 * from the current part if necessary.
	 *
	 * This will initially skip the preamble, so it's also possible to read
	 * from the stream before calling 'next_part'.
	 *
	 * If no part are available, 'false' is returned and the stream will be
	 * positioned on the epilogue.
	 *
	 * @param part_headers headers of the part
	 * @return 'true' if the stream is positionned on the next part, 'false'
	 *         otherwise
	 */
	[Version (since = "0.4")]
	public bool next_part (out Soup.MessageHeaders part_headers, Cancellable? cancellable = null) throws IOError {
		part_headers = new Soup.MessageHeaders (Soup.MessageHeadersType.MULTIPART);

		// skip until the next part
		string? line = null;
		do {
			line = data_base_stream.read_line (null, cancellable);

			// end of input (premature?)
			if (line == null) {
				return false;
			}

			// closing frontier (epilogue follows)
			if (line == "--%s--".printf (boundary)) {
				return false;
			}
		} while (line != "--%s".printf (boundary));

		// consume the part headers
		var headers = new StringBuilder ();

		do {
			line = data_base_stream.read_line (null, cancellable);

			if (line == null) {
				return false; // early end of input..?
			}

			headers.append_printf ("%s\r\n", line);
		} while (line != "");

		return Soup.headers_parse (headers.str, (int) headers.len, part_headers);
	}

	/**
	 * Obtain the next part asynchronously.
	 */
	[Version (since = "0.4")]
	public async bool next_part_async (int                     priority    = GLib.Priority.DEFAULT,
	                                   Cancellable?            cancellable = null,
	                                   out Soup.MessageHeaders part_headers) throws Error {
		return next_part (out part_headers, cancellable);
	}

	/**
	 * Read and skip boundaries, raising a 'EOF' before each occurences.
	 */
	public override ssize_t read (uint8[] buffer, Cancellable? cancellable = null) throws IOError {
		var needle = "\r\n--%s\r\n".printf (boundary);
		var epilogue_needle = "\r\n--%s--\r\n".printf (boundary);

		// peek the base stream such that it contains at least any of the needles
		var peek_buffer = new uint8[buffer.length + uint.max (needle.length, epilogue_needle.length)];
		try {
			data_base_stream.fill (peek_buffer.length);
		} catch (Error err) {
			critical ("%s (%s, %d)", err.message, err.domain.to_string (), err.code);
		}
		var bytes_read = data_base_stream.peek (peek_buffer);

		// check if the boundary is anywhere in the buffer
		var needle_in_buffer = memmem (peek_buffer[0:bytes_read], needle.data);

		if (needle_in_buffer != null) {
			return data_base_stream.read (buffer[0:((uint8*) needle_in_buffer - (uint8*) peek_buffer)], cancellable);
		}

		// check for epilogue boundary
		var epilogue_needle_in_buffer = memmem (peek_buffer[0:bytes_read], epilogue_needle.data);

		if (epilogue_needle_in_buffer != null) {
			return data_base_stream.read (buffer[0:((uint8*) epilogue_needle_in_buffer - (uint8*) peek_buffer)], cancellable);
		}

		return data_base_stream.read (buffer, cancellable);
	}

	public override bool close (Cancellable? cancellable = null) throws IOError {
		return base_stream.close (cancellable);
	}
}
