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

public static void test_view_push_ints () {
	var view = new View ();

	view.push_ints ("key", {0L, 1L, 2L});

	Ctpl.Value val = null;
	var popped     = view.environment.pop ("key", ref val);

	assert (popped);

	var size = 3;
	var arr = val.get_array_int ();

	assert (arr[0] == 0L);
	assert (arr[1] == 1L);
	assert (arr[2] == 2L);
}

public static void test_view_push_floats () {
	var view = new View ();

	view.push_floats ("key", {0.1, 0.2, 0.3});

	Ctpl.Value val = null;
	var popped     = view.environment.pop ("key", ref val);

	assert (popped);

	var size = 3;
	var arr = val.get_array_float ();

	assert (arr[0] == 0.1);
	assert (arr[1] == 0.2);
	assert (arr[2] == 0.3);
}

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

	unowned SList<string> arr = (SList<string>) val.get_array ();

	assert (arr.nth_data (1) == "a");
	assert (arr.nth_data (2) == "b");
	assert (arr.nth_data (3) == "c");
}

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

	unowned SList<long> arr = (SList<long>) val.get_array ();

	assert (arr.nth_data (0) == 0L);
	assert (arr.nth_data (1) == 1L);
	assert (arr.nth_data (2) == 2L);
}

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

	unowned SList<double?> arr = (SList<double?>) val.get_array ();

	assert (arr.nth_data (0) == 0.1);
	assert (arr.nth_data (1) == 0.2);
	assert (arr.nth_data (2) == 0.3);
}
