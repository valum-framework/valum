using Template;
using Valum;
using VSGI;

var app = new Router ();

var home_template = new Template.Template (null);

try {
	home_template.parse_resource ("/templates/home.html");
} catch (GLib.Error err) {
	error (err.message);
}

app.get ("/", (req, res) => {
	var scope = new Scope ();
	scope.set_string ("message", "Hello world!");
	return home_template.expand (res.body, scope);
});

Server.new ("http", handler: app).run ();

