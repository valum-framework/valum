using Valum;

var app = new Router ("/~user/valum/");

app.get ("", (req, res) => {
	var writer = new DataOutputStream (res);
	writer.put_string (req.uri.get_path ());
});

var server = new VSGI.SoupServer (app, 3003);

server.listen ();
