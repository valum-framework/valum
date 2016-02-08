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

using VSGI;

/**
 * @since 0.2
 */
public void test_vsgi_chunked_encoder () {
	var produced = new MemoryOutputStream (null, realloc, free);
	var convert = new ConverterOutputStream (produced, new ChunkedEncoder ());

	try {
		convert.write ("test".data);
	} catch (IOError err) {
		assert_not_reached ();
	}

	assert (9 == produced.data_size);
	for (int i = 0; i < produced.get_data ().length; i++)
		assert ("4\r\ntest\r\n".data[i] == produced.get_data ()[i]);

	try {
		convert.close ();
	} catch (IOError err) {
		assert_not_reached ();
	}

	assert (14 == produced.data_size);
	for (int i = 9; i < produced.data_size; i++)
		assert ("0\r\n\r\n".data[i - 9] == produced.get_data ()[i]);
}
