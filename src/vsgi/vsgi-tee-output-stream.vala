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
 * Pipe data into a base and a tee streams, similarly to the UNIX 'tee' utility.
 *
 * The base stream is always priviledged: it is always written and closed first.
 * Also, The best is done to replicate the written data into the tee stream,
 * erroring only if everything has been attempted. The tee operations are not
 * cancellable.
 *
 * @since 0.3
 */
public class VSGI.TeeOutputStream : FilterOutputStream {

	/**
	 * @since 0.3
	 */
	public OutputStream tee_stream { construct; get; }

	/**
	 * @since 0.3
	 */
	public TeeOutputStream (OutputStream base_stream, OutputStream tee_stream) {
		Object (base_stream: base_stream, tee_stream: tee_stream);
	}

	public override ssize_t write (uint8[] buffer, Cancellable? cancellable = null) throws IOError {
		var bytes_written = base_stream.write (buffer, cancellable);

		// we want the tee stream to replicate as much as possible the
		// base stream, so no cancelling nor extra write
		buffer.length = (int) bytes_written;
		size_t tee_bytes_written;
		tee_stream.write_all (buffer, out tee_bytes_written);

		return bytes_written;
	}

	public override bool close (Cancellable? cancellable = null) throws IOError {
		return base_stream.close (cancellable) && tee_stream.close ();
	}
}
