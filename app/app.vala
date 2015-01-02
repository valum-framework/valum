using Soup;
using Valum;

var app = new Valum.Router();
var lua = new Valum.Script.Lua();
var mcd = new Valum.NoSQL.Mcached();

mcd.add_server("127.0.0.1", 11211);

// default route
app.get("", (req, res) => {
	var template =  new Valum.View.Tpl.from_path("app/templates/home.html");

	template.vars["path"] = req.message.uri.get_path ();
	template.vars["query"] = req.message.uri.get_query ();
	template.vars["headers"] = req.headers;

	res.append(template.render());
});

// hello world! (compare with Node.js!)
app.get("hello", (req, res) => {
	res.mime = "text/plain";
	res.append("Hello world\n");
});

// hello with a trailing slash
app.get("hello/", (req, res) => {
	res.mime = "text/plain";
	res.append("Hello world\n");
});

// example using route parameter
app.get("hello/<id>", (req, res) => {
	res.mime = "text/plain";
	res.append("hello %s!".printf(req.params["id"]));
});

// example using a typed route parameter
app.get("users/<int:id>/<action>", (req, res) => {
	var id   = req.params["id"];
	var test = req.params["action"];
	res.mime = "text/plain";
	res.append(@"id\t=> $id\n");
	res.append(@"action\t=> $test");
});

// lua scripting
app.get("lua", (req, res) => {
	res.append(lua.eval("""
		require "markdown"
		return markdown('## Hello from lua.eval!')
	"""));

	res.append(lua.run("app/hello.lua"));
});

app.get("lua.haml", (req, res) => {
	res.append(lua.run("app/haml.lua"));
});

// precompiled template
var tpl = new Valum.View.Tpl.from_string("""
   <p> hello {foo} </p>
   <p> hello {bar} </p>
   <ul>
	 { for el in arr }
	   <li> { el } </li>
	 { end }
   </ul>
""");

// Ctpl template rendering
app.get("ctpl/<foo>/<bar>", (req, res) => {

	var arr = new Gee.ArrayList<Value?>();
	arr.add("omg");
	arr.add("typed hell");

	tpl.vars["foo"] = req.params["foo"];
	tpl.vars["bar"] = req.params["bar"];
	tpl.vars["arr"] = arr;
	tpl.vars["int"] = 1;

	res.append(tpl.render ());
});

// memcached
app.get("memcached/get/<key>", (req, res) => {
	var value = mcd.get(req.params["key"]);
	res.append(value);
});

// TODO: rewrite using POST
app.get("memcached/set/<key>/<value>", (req, res) => {
	if (mcd.set(req.params["key"], req.params["value"])) {
		res.append("Ok! Pushed.");
	} else {
		res.append("Fail! Not Pushed...");
	}
});

// FIXME: Optimize routing...
// for (var i = 0; i < 1000; i++) {
//		print(@"New route /$i\n");
//		var route = "%d".printf(i);
//		app.get(route, (req, res) => { res.append(@"yo 1"); });
// }

// scoped routing
app.scope("admin", (adm) => {
	adm.scope("fun", (fun) => {
		fun.get("hack", (req, res) => {
				var time = new DateTime.now_utc();
				res.mime = "text/plain";
				res.append("It's %s around here!\n".printf(time.format("%H:%M")));
		});
		fun.get("heck", (req, res) => {
				res.mime = "text/plain";
				res.append("Wuzzup!");
		});
	});
});

app.get("<any:path>", (req, res) => {
	var template =  new Valum.View.Tpl.from_path("app/templates/404.html");

	template.vars["path"] = req.path;

	res.status = 404;
	res.append(template.render());
});

#if (FCGI)

FastCGI.init ();

FastCGI.request request;
FastCGI.request.init (out request);

while (true) {
	// accept a new request
	if (request.accept () < 0)
		break;

	// handle the request
	app.fastcgi_request_handler (request);

	assert(request.out.is_closed);
}

request.close ();

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
