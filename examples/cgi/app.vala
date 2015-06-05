using Valum;
using VSGI.CGI;

var app = new Router ();

app.get ("", (req, res) => {
	res.body.write ("Hello world!".data);
});

new Server (app.handle).run ();
