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
using VSGI;

public int main (string[] args) {
	Test.init (ref args);

	Test.add_func ("/multipart_input_stream", () => {
		MultipartInputStream @in;

		try {
			@in = new MultipartInputStream (File.new_for_path (Test.get_filename (Test.FileType.DIST, "data", "multipart", "simple-message")).read (),
			                                "simple boundary");

		} catch (Error err) {
			assert_not_reached ();
		}

		Soup.MessageHeaders part_headers;

		var preamble    = new MemoryOutputStream.resizable ();
		var first_part  = new MemoryOutputStream.resizable ();
		var second_part = new MemoryOutputStream.resizable ();
		var epilogue    = new MemoryOutputStream.resizable ();

		try {
			preamble.splice (@in, OutputStreamSpliceFlags.NONE);
			assert (153 == preamble.get_data_size ());
		} catch (IOError err) {
			assert_not_reached ();
		}

		try {
			assert (@in.next_part (out part_headers));
			first_part.splice (@in, OutputStreamSpliceFlags.NONE);
			assert (77 == first_part.get_data_size ());
		} catch (IOError err) {
			assert_not_reached ();
		}

		try {
			assert (@in.next_part (out part_headers));
			second_part.splice (@in, OutputStreamSpliceFlags.NONE);
			assert (75 == second_part.get_data_size ());
			assert ('\r' == second_part.get_data ()[73]);
			assert ('\n' == second_part.get_data ()[74]);
		} catch (IOError err) {
			assert_not_reached ();
		}

		try {
			assert (!@in.next_part (out part_headers));
			epilogue.splice (@in, OutputStreamSpliceFlags.NONE);
			assert (50 == epilogue.get_data_size ());
		} catch (IOError err) {
			assert_not_reached ();
		}
	});

	Test.add_func ("/multipart_output_stream", () => {
		var mos = new MemoryOutputStream.resizable ();
		var @out = new MultipartOutputStream (mos, "simple boundary");

		try {
			@out.new_part ();
			@out.write_all ("Hello world!".data, null);
		} catch (IOError err) {
			assert_not_reached ();
		}

		@out.epilogue = "foo bar";

		try {
			@out.close ();
		} catch (IOError err) {
			assert_not_reached ();
		}

		var @in = new MultipartInputStream (new MemoryInputStream.from_bytes (mos.steal_as_bytes ()), "simple boundary");

		Soup.MessageHeaders part_headers;
		try {
			assert (@in.next_part (out part_headers));
		} catch (Error err) {
			assert_not_reached ();
		}
		uint8 buffer[1024];
		size_t bytes_read;
		try {
			@in.read_all (buffer, out bytes_read);
		} catch (IOError err) {
			assert_not_reached ();
		}
		assert (12 == bytes_read);
		assert (Memory.cmp ("Hello world!".data, buffer, 12) == 0);

		try {
			assert (!@in.next_part (out part_headers));
			@in.read_all (buffer, out bytes_read);
		} catch (IOError err) {
			assert_not_reached ();
		}
		assert (7 == bytes_read);
		assert (Memory.cmp ("foo bar".data, buffer, 7) == 0);
	});

	return Test.run ();
}
