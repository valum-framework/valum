using Valum;

/**
 * @since 0.1
 */
public static void test_view_push_string () {
	var view = new View ();
	view.push_string ("key", "value");

	Ctpl.Value val = null;
	var popped     = view.environment.pop ("key", ref val);

	assert (popped);
	assert (val.get_string () == "value");
}

/**
 * @since 0.1
 */
public static void test_view_push_int () {
	var view = new View ();
	view.push_int ("key", 5);

	Ctpl.Value val = null;
	var popped     = view.environment.pop ("key", ref val);

	assert (popped);
	assert (val.get_int () == 5);
}

/**
 * @since 0.1
 */
public static void test_view_push_float () {
	var view = new View ();
	view.push_float ("key", 5.5);

	Ctpl.Value val = null;
	var popped     = view.environment.pop ("key", ref val);

	assert (popped);
	assert (val.get_float () == 5.5);
}

/**
 * @since 0.1
 */
public static void test_view_push_strings () {
	var view = new View ();

	view.push_strings ("key", {"a", "b", "c"});

	Ctpl.Value val = null;
	var popped     = view.environment.pop ("key", ref val);

	assert (popped);

	var arr = val.get_array_string ();

	assert (arr[0] == "a");
	assert (arr[1] == "b");
	assert (arr[2] == "c");
}

/**
 * @since 0.1
 */
public static void test_view_push_ints () {
	var view = new View ();

	view.push_ints ("key", {0L, 1L, 2L});

	Ctpl.Value val = null;
	var popped     = view.environment.pop ("key", ref val);

	assert (popped);

	var arr = val.get_array_int ();

	assert (arr[0] == 0L);
	assert (arr[1] == 1L);
	assert (arr[2] == 2L);
}

/**
 * @since 0.1
 */
public static void test_view_push_floats () {
	var view = new View ();

	view.push_floats ("key", {0.1, 0.2, 0.3});

	Ctpl.Value val = null;
	var popped     = view.environment.pop ("key", ref val);

	assert (popped);

	var arr = val.get_array_float ();

	assert (arr[0] == 0.1);
	assert (arr[1] == 0.2);
	assert (arr[2] == 0.3);
}

/**
 * @since 0.1
 */
public static void test_view_push_collection_strings () {
	var view       = new View ();
	var collection = new Gee.ArrayList<string> ();

	collection.add ("a");
	collection.add ("b");
	collection.add ("c");

	view.push_collection ("key", collection);

	Ctpl.Value val = null;
	var popped     = view.environment.pop ("key", ref val);

	assert (popped);

	var arr = val.get_array_string ();

	assert (arr[0] == "a");
	assert (arr[1] == "b");
	assert (arr[2] == "c");
}

/**
 * @since 0.1
 */
public static void test_view_push_collection_ints () {
	var view       = new View ();
	var collection = new Gee.ArrayList<long> ();

	collection.add (0L);
	collection.add (1L);
	collection.add (2L);

	view.push_collection ("key", collection);

	Ctpl.Value val = null;
	var popped     = view.environment.pop ("key", ref val);

	assert (popped);

	var arr = val.get_array_int ();

	assert (arr[0] == 0L);
	assert (arr[1] == 1L);
	assert (arr[2] == 2L);
}

/**
 * @since 0.1
 */
public static void test_view_push_collection_floats () {
	var view       = new View ();
	var collection = new Gee.ArrayList<double?> ();

	collection.add (0.1);
	collection.add (0.2);
	collection.add (0.3);

	view.push_collection ("key", collection);

	Ctpl.Value val = null;
	var popped     = view.environment.pop ("key", ref val);

	assert (popped);

	var arr = val.get_array_float ();

	assert (arr.length == 3);
	/*
	assert (arr[0] == 0.1);
	assert (arr[1] == 0.2);
	assert (arr[2] == 0.3);
	*/
}

/**
 * @since 0.1
 */
public static void test_view_push_map () {
	var view  = new View ();
	var table = new Gee.HashMap<string, Value?> ();

	table["key"] = "value";

	view.push_map ("key", table);

	table.foreach ((e) => {
		Ctpl.Value val = null;
		var popped     = view.environment.pop ("key_" + e.key, ref val);

		assert (popped);

		assert (val.get_string () == e.value.get_string ());

		return true;
	});
}

/**
 * @since 0.1
 */
public static void test_view_push_string_map () {
	var view  = new View ();
	var table = new Gee.HashMap<string, string> ();

	table["key"] = "value";

	view.push_string_map ("key", table);

	table.foreach ((e) => {
		Ctpl.Value val = null;
		var popped     = view.environment.pop ("key_" + e.key, ref val);

		assert (popped);

		assert (val.get_string () == e.value);

		return true;
	});
}

/**
 * @since 0.1
 */
public static void test_view_push_int_map () {
	var view  = new View ();
	var table = new Gee.HashMap<string, int> ();

	table["key"] = 5;

	view.push_int_map ("key", table);

	table.foreach ((e) => {
		Ctpl.Value val = null;
		var popped     = view.environment.pop ("key_" + e.key, ref val);

		assert (popped);

		assert (val.get_int () == e.value);

		return true;
	});
}

/**
 * @since 0.1
 */
public static void test_view_push_string_multimap () {
	var view  = new View ();
	var table = new Gee.HashMultiMap<string, string> ();

	table["key"] = "value";

	view.push_string_multimap ("key", table);

	table.map_iterator ().foreach ((k, v) => {
		Ctpl.Value val = null;
		var popped     = view.environment.pop ("key_" + k, ref val);

		assert (popped);

		assert (val.get_array_string ()[0] == v);
		return true;
	});
}

/**
 * @since 0.1
 */
public static void test_view_push_int_multimap () {
	var view  = new View ();
	var table = new Gee.HashMultiMap<string, int> ();

	table["key"] = 5;

	view.push_int_multimap ("key", table);

	table.map_iterator ().foreach ((k, v) => {
		Ctpl.Value val = null;
		var popped     = view.environment.pop ("key_" + k, ref val);

		assert (popped);

		assert (val.get_array_int ()[0] == v);
		return true;
	});
}

public static void test_view_push_hashtable () {
	var view  = new View ();
	var table = new HashTable<string, Value?> (str_hash, str_equal);

	table["key"] = "value";

	view.push_hashtable ("key", table);

	table.foreach ((k, v) => {
		Ctpl.Value val = null;
		var popped     = view.environment.pop ("key_" + k, ref val);

		assert (popped);

		assert (val.get_string () == v.get_string ());
	});
}

public static void test_view_push_string_hashtable () {
	var view  = new View ();
	var table = new HashTable<string, string> (str_hash, str_equal);

	table["key"] = "value";

	view.push_string_hashtable ("key", table);

	table.foreach ((k, v) => {
		Ctpl.Value val = null;
		var popped     = view.environment.pop ("key_" + k, ref val);

		assert (popped);

		assert (val.get_string () == v);
	});
}

public static void test_view_push_int_hashtable () {
	var view  = new View ();
	var table = new HashTable<string, long> (str_hash, str_equal);

	table["key"] = 5;

	view.push_int_hashtable ("key", table);

	table.foreach ((k, v) => {
		Ctpl.Value val = null;
		var popped     = view.environment.pop ("key_" + k, ref val);

		assert (popped);

		assert (val.get_int () == v);
	});
}

/**
 * @since 0.1
 */
public static void test_view_push_value_null () {
	var view = new View ();

	view.push_value ("key", null);

	Ctpl.Value val = null;
	var popped     = view.environment.pop ("key", ref val);

	assert (popped);

	assert (val.get_string () == "null");
}
