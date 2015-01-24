using Soup;
using Valum;

var app = new Valum.Router();
var lua = new Valum.Script.Lua();
var mcd = new Valum.NoSQL.Mcached();

mcd.add_server("127.0.0.1", 11211);

// extra route types
app.types["permutations"] = "abc|acb|bac|bca|cab|cba";

// default route
app.get("", (req, res) => {
	var template =  new Valum.View.Tpl.from_path("app/templates/home.html");

	template.vars["path"]    = req.message.uri.get_path ();
	template.vars["query"]   = req.message.uri.get_query ();
	template.vars["headers"] = req.headers;

	res.append(template.render());
});

app.get("custom-route-type/<permutations:p>", (req, res) => {
	res.append(req.params["p"]);
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

app.scope("urlencoded-data", (inner) => {
	inner.get("", (req, res) => {
		res.append(
		"""
	<!DOCTYPE html>
	<html>
	  <body>
	    <form method="post">
          <textarea name="data"></textarea>
		  <button type="submit">submit</button>
		</form>
	  </body>
	</html>
	"""
	);
	});

	inner.post("", (req, res) => {

		var data = Soup.Form.decode ((string) req.body.data);

		data.foreach((key, value) => {
			res.append ("%s: %s".printf(key, value));
		});
	});
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

app.method ("GET", "custom-method", (req, res) => {
	res.append (req.message.method);
});

app.regex ("GET", /\/custom-regular-expression$/, (req, res) => {
	res.append ("This route was matched using a custom regular expression.");
});

app.get("<any:path>", (req, res) => {
	var template =  new Valum.View.Tpl.from_path("app/templates/404.html");

	template.vars["path"] = req.path;

	res.status = 404;
	res.append(template.render());
});

var server = new Soup.Server(Soup.SERVER_SERVER_HEADER, Valum.APP_NAME);

// bind the application to the server
server.add_handler("/", app.soup_handler);

server.listen_all(3003, Soup.ServerListenOptions.IPV4_ONLY);

foreach (var uri in server.get_uris ()) {
	message("listening on %s", uri.to_string (false));
}

// run the server
server.run ();
