public int main (string[] args) {

	Test.init (ref args);

	Test.add_func ("/valum/route/from_rule", test_valum_route_from_rule);

	// register test functions
	Test.add_func ("/fastcgi/listen", test_fastcgi_listen);

	return Test.run ();
}
