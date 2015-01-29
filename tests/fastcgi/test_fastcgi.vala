using Valum;
using VSGI;

public static void test_fastcgi_listen () {

	var app = new Router ();

	app.get ("test", (req, res) => {

	});

	var server = new FastCGIServer (app);
}
