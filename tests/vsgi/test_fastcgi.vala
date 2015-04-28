using Valum;

/**
 * @since 0.1
 */
public static void test_fastcgi_listen () {

	var app = new Router ();

	app.get ("test", (req, res) => {

	});

	var server = new VSGI.FastCGI.Server (app);
}
