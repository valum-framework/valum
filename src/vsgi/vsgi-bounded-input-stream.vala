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
 * Bounded input stream that provide a end-of-file behaviour when a a certain
 * number of bytes has been read from the base stream.
 */
[Version (since = "0.3")]
public class VSGI.BoundedInputStream : FilterInputStream {

	/**
	 * Number of bytes read from the base stream.
	 */
	private int64 bytes_read = 0;

	/**
	 * The {@link int64} type is used to remain consistent with
	 * {@link Soup.MessageHeaders.get_content_length}
	 */
	[Version (since = "0.3")]
	public int64 content_length { construct; get; }

	/**
	 * {@inheritDoc}
	 *
	 * @param content_length number of bytes that can be read from the base
	 *                       stream
	 */
	[Version (since = "0.3")]
	public BoundedInputStream (InputStream base_stream, int64 content_length) {
		Object (base_stream: base_stream, content_length: content_length);
	}

	/**
	 * {@inheritDoc}
	 *
	 * Ensures that the read buffer is smaller than the remaining bytes to
	 * read from the base stream. If no more data is available, it produces
	 * an artificial EOF.
	 */
	public override ssize_t read (uint8[] buffer, Cancellable? cancellable = null) throws IOError {
		if (bytes_read >= content_length)
			return 0; // EOF

		if (buffer.length > (content_length - bytes_read)) {
			// the 'int' cast is guarantee since difference is smaller than
			// the buffer length
			buffer.length = (int) (content_length - bytes_read);
		}

		var ret = base_stream.read (buffer, cancellable);

		if (ret > 0)
			bytes_read += ret;

		return ret;
	}

	/**
	 * {@inheritDoc}
	 */
	public override bool close (Cancellable? cancellable = null) throws IOError {
		return base_stream.close (cancellable);
	}
}
