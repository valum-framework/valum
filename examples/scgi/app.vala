using Valum;
using VSGI.SCGI;

var app = new Router ();

app.get ("", (req, res) => {
	res.body.write_all ("Hello world!".data, null);

});
app.get ("async", (req, res) => {
	res.body.write_all_async ("Hello world!".data, Priority.DEFAULT, null);
});

new Server ("org.valum.example.SCGI", app.handle).run ();
