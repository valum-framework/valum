using VSGI;

/**
 * @since 0.2
 */
public void test_vsgi_chunked_encoder () {
	var produced = new MemoryOutputStream (null, realloc, free);
	var convert = new ConverterOutputStream (produced, new ChunkedEncoder ());

	convert.write ("test".data);

	assert (9 == produced.data_size);
	for (int i = 0; i < produced.get_data ().length; i++)
		assert ("4\r\ntest\r\n".data[i] == produced.get_data ()[i]);

	convert.close ();

	assert (14 == produced.data_size);
	for (int i = 9; i < produced.data_size; i++)
		assert ("0\r\n\r\n".data[i - 9] == produced.get_data ()[i]);
}
