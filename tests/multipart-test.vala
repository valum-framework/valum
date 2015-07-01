
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

		@out.close ();

		var @in = new MultipartInputStream (new MemoryInputStream.from_bytes (mos.steal_as_bytes ()), "simple boundary");

		Soup.MessageHeaders part_headers;
		assert (@in.next_part (out part_headers));
		uint8 buffer[1024];
		size_t bytes_read;
		@in.read_all (buffer, out bytes_read);
		assert (12 == bytes_read);
		assert (Memory.cmp ("Hello world!".data, buffer, 12) == 0);

		assert (!@in.next_part (out part_headers));
		@in.read_all (buffer, out bytes_read);
		assert (7 == bytes_read);
		assert (Memory.cmp ("foo bar".data, buffer, 7) == 0);
	});

	return Test.run ();
}
