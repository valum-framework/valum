using Tmpl;
using Valum;
using Valum.ContentNegotiation;
using VSGI;

var app = new Router ();

var home = new Template (new TemplateLocator ());

try {
	home.parse_resource ("/templates/home.html");
} catch (GLib.Error err) {
	error (err.message);
}

app.use (basic ());
app.use ("text/html");

app.get ("/", (req, res) => {
	var scope = new Scope ();
	return home.expand (res.body, scope);
});

Server.new ("http", handler: app).run ();

