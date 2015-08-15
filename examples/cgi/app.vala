using Valum;
using VSGI.CGI;

var app = new Router ();

app.get ("", (req, res) => {
	res.body.write_all ("Hello world!".data, null);
});

new Server ("org.valum.example.CGI", app.handle).run ();
