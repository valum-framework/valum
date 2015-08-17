using Valum;
using VSGI.Soup;

var app = new Router ();

app.get ("", (req, res) => {
	var builder   = new Json.Builder ();
	var generator = new Json.Generator ();

	builder.begin_object ();

	builder.set_member_name ("latitude");
	builder.add_double_value (5.40000123);

	builder.set_member_name ("longitude");
	builder.add_double_value (56.34318);

	builder.set_member_name ("elevation");
	builder.add_double_value (2.18);

	builder.end_object ();

	generator.root   = builder.get_root ();
	generator.pretty = true;

	res.headers.set_content_type ("application/json", null);

	generator.to_stream (res.body);
});

new Server ("org.valum.example.JSON", app.handle).run ({"app", "--all"});
