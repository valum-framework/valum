using Valum;
using VSGI.SCGI;

var app = new Router ();

app.get ("", (req, res) => {
	res.body.write_all ("Hello world!".data, null);
});

new Server ("org.valum.example.SCGI", app.handle).run ();
