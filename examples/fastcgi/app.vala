using Valum;

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

app.get("<any:path>", (req, res) => {
	res.status = 404;

	var writer = new DataOutputStream (res);
	writer.put_string ("404 - Not found");
});

var server = new VSGI.FastCGIServer.from_socket (app, "valum.socket", 0);

server.listen ();
