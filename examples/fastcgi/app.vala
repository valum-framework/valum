using Valum;

public static void main (string[] args) {
	var app   = new Router ();
	var timer = new Timer ();

	app.handler.connect ((req, res) => {
		timer.start();
	});

	app.handler.connect_after ((req, res) => {
		timer.stop ();
		var elapsed = timer.elapsed ();
		res.headers.append ("X-Runtime", "%8.3fms".printf (elapsed * 1000));
		message ("%s computed in %8.3fms", req.uri.get_path (), elapsed * 1000);
	});

	// default route
	app.get("", (req, res) => {
		var writer = new DataOutputStream (res);
		writer.put_string ("Hello world!");
	});

	app.get ("random/<int:size>", (req, res) => {
		var size   = int.parse (req.params["size"]);
		var writer = new DataOutputStream (res);

		for (; size > 0; size--) {
			// write byte to byte
			writer.put_uint32 (Random.next_int ());
		}
	});

	app.get("<any:path>", (req, res) => {
		res.status = 404;

		var writer = new DataOutputStream (res);
		writer.put_string ("404 - Not found");
	});

	if (args.length != 2)
		error ("specify the FastCGI socket location ./fastcgi <socket>");

	stdout.printf(args[1]);

	var server = new VSGI.FastCGIServer.from_socket (app, args[1], 0);

	server.listen ();
}
