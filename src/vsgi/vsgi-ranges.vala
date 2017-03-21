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
 * Convert data by selecting subsequences satisfying a set of 'Range' headers.
 *
 * Typically, this is used along with {@link Soup.MessageHeaders.get_ranges}.
 *
 * Due to the streaming nature of this converter, the end-range are not
 * supported since the amount of data that will be converted is now known in
 * advance.
 */
[Version (since = "0.4")]
public class VSGI.Ranges : Object, Converter {

	[Version (since = "0.4")]
	public SList<Soup.Range?> ranges { get; owned construct; }

	private int64 position = 0;

	[Version (since = "0.4")]
	public Ranges (Soup.Range[] ranges) {
		var _ranges = new SList<Soup.Range?> ();
		foreach (var range in ranges) {
			_ranges.append (range);
		}
		base (ranges: _ranges);
	}

	public ConverterResult convert (uint8[] inbuf, uint8[] outbuf, ConverterFlags flags, out size_t bytes_read, out size_t bytes_written) {
		foreach (var range in ranges) {
			// suffix range are not supported
			if (range.start < -1) {
				continue;
			}

			size_t bytes_to_copy = 0;

			if (range.end == -1) {
				bytes_to_copy = size_t.min (inbuf.length, outbuf.length);
			}

			else if (position >= range.start && position <= range.end) {
				bytes_to_copy = size_t.min (bytes_to_copy, (size_t) (range.end - position + 1));
			}

			else {
				continue;
			}

			Memory.copy (outbuf, inbuf, bytes_to_copy);

			bytes_read    = bytes_to_copy;
			bytes_written = bytes_to_copy;

			position += bytes_to_copy;

			return ConverterResult.CONVERTED;
		}

		/* since it's unsatsifiable, we skip the inbuf */
		bytes_read    = inbuf.length;
		bytes_written = 0;

		if (ConverterFlags.INPUT_AT_END in flags) {
			return ConverterResult.FINISHED;
		} else {
			return ConverterResult.CONVERTED;
		}
	}

	public void reset () {
		position = 0;
	}
}
