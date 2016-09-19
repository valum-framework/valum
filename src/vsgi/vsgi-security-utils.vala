namespace VSGI {

	/**
	 * Test for string equality in constant-time.
	 *
	 * Note that the length of 'b' is used and any user-provided string should
	 * be passed as second argument.
	 *
	 * @since 0.3
	 *
	 * @param a the expected string
	 * @param b the user-provided string
	 *
	 * @return 'true' if the strings are byte-per-byte equal in the order of
	 *         'b.length'
	 */
	internal bool str_const_equal (string a, string b) {
		var match = 0;

		for (var i = 0; i < b.data.length; i++)
			match |= i >= a.data.length ? 1 : a.data[i] ^ b.data[i];

		if (b.data.length < a.data.length)
			return false;

		return match == 0;
	}
}
