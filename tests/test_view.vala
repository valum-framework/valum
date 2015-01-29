using Valum;

/**
 * @since 0.1
 */
public static void test_view_push_string () {
	var view = new View ();
	view.push_string ("key", "value");

	Ctpl.Value val = null;
	var popped = view.environment.pop ("key", ref val);

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
	var popped = view.environment.pop ("key", ref val);

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
	var popped = view.environment.pop ("key", ref val);

	assert (popped);
	assert (val.get_float () == 5.5);
}
