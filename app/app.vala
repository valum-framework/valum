using Soup;
using Valum;

var app = new Valum.Router();
var lua = new Valum.Script.Lua();
var mcd = new Valum.NoSQL.Mcached();

mcd.add_server("127.0.0.1", 11211);

// default route
app.get("", (req, res) => {
	var template =  new Valum.View.Tpl.from_path("app/templates/home.html");

	template.vars["path"] = req.path;
	template.vars["headers"] = req.headers;

	template.stream (res.body);
});

app.get("headers", (req, res) => {

	var writer = new DataOutputStream(res.body);

	res.mime = "text/plain";
	req.headers.map_iterator().foreach((name, header) => {
		writer.put_string ("%s: %s\n".printf(name, header));
		return true;
	});
});

// hello world! (compare with Node.js!)
app.get("hello", (req, res) => {
	var writer = new DataOutputStream(res.body);
	res.mime = "text/plain";
	writer.put_string("Hello world\n");
});

// hello with a trailing slash
app.get("hello/", (req, res) => {
	var writer = new DataOutputStream(res.body);
	res.mime = "text/plain";
	writer.put_string("Hello world\n");
});

// example using route parameter
app.get("hello/<id>", (req, res) => {
	var writer = new DataOutputStream(res.body);
	res.mime = "text/plain";
	writer.put_string("hello %s!".printf(req.params["id"]));
});

// example using a typed route parameter
app.get("users/<int:id>/<action>", (req, res) => {
	var id   = req.params["id"];
	var test = req.params["action"];
	var writer = new DataOutputStream(res.body);
	res.mime = "text/plain";
	writer.put_string(@"id\t=> $id\n");
	writer.put_string(@"action\t=> $test");
});

// lua scripting
app.get("lua", (req, res) => {
	var writer = new DataOutputStream(res.body);
	writer.put_string(lua.eval("""
		require "markdown"
		return markdown('## Hello from lua.eval!')
	"""));

	writer.put_string(lua.run("app/hello.lua"));
});

app.get("lua.haml", (req, res) => {
	var writer = new DataOutputStream(res.body);
	writer.put_string(lua.run("app/haml.lua"));
});


// Ctpl template rendering
app.get("ctpl/<foo>/<bar>", (req, res) => {

	var tpl = new Valum.View.Tpl.from_string("""
	   <p> hello {foo} </p>
	   <p> hello {bar} </p>
	   <ul>
		 { for el in arr }
		   <li> { el } </li>
		 { end }
	   </ul>
	""");

	var arr = new Gee.ArrayList<Value?>();
	arr.add("omg");
	arr.add("typed hell");

	tpl.vars["foo"] = req.params["foo"];
	tpl.vars["bar"] = req.params["bar"];
	tpl.vars["arr"] = arr;
	tpl.vars["int"] = 1;

	tpl.stream (res.body);
});

// streamed Ctpl template
app.get("ctpl/streamed", (req, res) => {

	var tpl = new Valum.View.Tpl.from_path("app/templates/home.html");

	tpl.stream(res.body);
});

// memcached
app.get("memcached/get/<key>", (req, res) => {
	var value = mcd.get(req.params["key"]);
	var writer = new DataOutputStream(res.body);
	writer.put_string(value);
});

// TODO: rewrite using POST
app.get("memcached/set/<key>/<value>", (req, res) => {
	var writer = new DataOutputStream(res.body);
	if (mcd.set(req.params["key"], req.params["value"])) {
		writer.put_string("Ok! Pushed.");
	} else {
		writer.put_string("Fail! Not Pushed...");
	}
});

// FIXME: Optimize routing...
// for (var i = 0; i < 1000; i++) {
//		print(@"New route /$i\n");
//		var route = "%d".printf(i);
//		app.get(route, (req, res) => { res.body.put_string(@"yo 1"); });
// }

// scoped routing
app.scope("admin", (adm) => {
	adm.scope("fun", (fun) => {
		fun.get("hack", (req, res) => {
				var time = new DateTime.now_utc();
				var writer = new DataOutputStream(res.body);
				res.mime = "text/plain";
				writer.put_string("It's %s around here!\n".printf(time.format("%H:%M")));
		});
		fun.get("heck", (req, res) => {
				var writer = new DataOutputStream(res.body);
				res.mime = "text/plain";
				writer.put_string("Wuzzup!");
		});
	});
});

app.get("<any:path>", (req, res) => {
	var template =  new Valum.View.Tpl.from_path("app/templates/404.html");

	template.vars["path"] = req.path;

	res.status = 404;
	template.stream (res.body);
});

#if (FCGI)

var loop = new MainLoop ();

FastCGI.init ();

FastCGI.request request;
FastCGI.request.init (out request);

var source = new TimeoutSource (0);

source.set_callback(() => {

	message("accepting a new request...");

	// accept a new request
	var status = request.accept ();

	if (status < 0) {
		warning ("could not accept a request (code %d)", status);
		request.close ();
		loop.quit ();
		return false;
	}

	// handle the request using FastCGI handler
	app.fastcgi_request_handler (request);

	request.finish ();

	assert (request.in.is_closed);
	assert (request.out.is_closed);

	return true;
});

source.attach (loop.get_context ());

loop.run ();

#else

// Soup server example
var server = new Soup.Server(Soup.SERVER_SERVER_HEADER, Valum.APP_NAME);

// bind the application to the server
server.add_handler("/", app.soup_handler);

server.listen_all(3003, Soup.ServerListenOptions.IPV4_ONLY);

foreach (var uri in server.get_uris ()) {
	message("listening on %s", uri.to_string (false));
}

// run the server
server.run ();

#endif
