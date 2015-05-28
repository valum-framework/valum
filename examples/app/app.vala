using Valum;
using VSGI.Soup;

var app = new Router ();
var lua = new Script.Lua ();
var mcd = new NoSQL.Mcached ();

mcd.add_server ("127.0.0.1", 11211);

// extra route types
app.types["permutations"] = /abc|acb|bac|bca|cab|cba/;

// default route
app.get ("", (req, res, end) => {
	var template = new View.from_stream (resources_open_stream ("/templates/home.html", ResourceLookupFlags.NONE));
	template.stream (res.body);

	res.body.close ();

	end ();
});

app.methods ({VSGI.Request.GET, VSGI.Request.POST}, "get-and-post", (req, res) => {
	res.body.write ("Matches GET and POST".data);
});

app.all (null, (req, res, end, next) => {
	res.headers.append ("Server", "Valum/1.0");
	next ();
});

app.all ("all", (req, res, end) => {
	res.body.write ("Matches all HTTP methods".data);
	end ();
});

// default route
app.get ("gzip", (req, res, end) => {
	var template = new View.from_stream (resources_open_stream ("/templates/home.html", ResourceLookupFlags.NONE));

	res.headers.append ("Content-Encoding", "gzip");
	res.body = new ConverterOutputStream (res.body, new ZlibCompressor (ZlibCompressorFormat.GZIP));

	template.stream (res.body);
	end ();
});

app.get ("query", (req, res, end) => {
	var writer = new DataOutputStream (res.body);

	res.headers.set_content_type ("text/plain", null);

	if (req.query != null) {
		req.query.foreach ((k, v) => {
			writer.put_string ("%s: %s\n".printf (k, v));
		});
	}

	end ();
});

app.get ("headers", (req, res, end) => {
	var writer = new DataOutputStream (res.body);

	res.headers.set_content_type ("text/plain", null);

	req.headers.foreach ((name, header) => {
		writer.put_string ("%s: %s\n".printf (name, header));
	});

	end ();
});

app.get ("cookies", (req, res, end) => {
	var writer = new DataOutputStream (res.body);

	res.headers.set_content_type ("text/plain", null);

	// write cookies in response
	writer.put_string ("Cookie\n");
	foreach (var cookie in req.cookies) {
		writer.put_string ("%s: %s\n".printf (cookie.name, cookie.value));
	}

	end ();
});

app.get ("custom-route-type/<permutations:p>", (req, res, end) => {
	var writer = new DataOutputStream (res.body);
	writer.put_string (req.params["p"]);
	end ();
});

// hello world! (compare with Node.js!)
app.get ("hello", (req, res, end) => {
	var writer = new DataOutputStream (res.body);
	res.headers.set_content_type ("text/plain", null);
	writer.put_string ("Hello world\n");
	end ();
});

// hello with a trailing slash
app.get ("hello/", (req, res, end) => {
	var writer = new DataOutputStream (res.body);
	res.headers.set_content_type ("text/plain", null);
	writer.put_string ("Hello world\n");
	end ();
});

// example using route parameter
app.get ("hello/<id>", (req, res, end) => {
	var writer = new DataOutputStream (res.body);
	res.headers.set_content_type ("text/plain", null);
	writer.put_string ("hello %s!".printf (req.params["id"]));
	end ();
});

app.scope ("urlencoded-data", (inner) => {
	inner.get ("", (req, res, end) => {
		var writer = new DataOutputStream (res.body);
		writer.put_string (
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
		""");
		end ();
	});

	inner.post ("", (req, res, end) => {
		var writer = new DataOutputStream (res.body);
		var data   = new MemoryOutputStream (null, realloc, free);

		data.splice (req.body, OutputStreamSpliceFlags.CLOSE_SOURCE);

		Soup.Form.decode ((string) data.get_data ()).foreach ((k, v) => {
			writer.put_string ("%s: %s".printf (k, v));
		});

		end ();
	});
});

// example using a typed route parameter
app.get ("users/<int:id>/<action>", (req, res, end) => {
	var id     = req.params["id"];
	var test   = req.params["action"];
	var writer = new DataOutputStream (res.body);

	res.headers.set_content_type ("text/plain", null);

	writer.put_string (@"id\t=> $id\n");
	writer.put_string (@"action\t=> $test");

	end ();
});

// lua scripting
app.get ("lua", (req, res, end) => {
	var writer = new DataOutputStream (res.body);
	writer.put_string (lua.eval ("""
		require "markdown"
		return markdown('## Hello from lua.eval!')
	"""));

	writer.put_string (lua.run ("examples/app/hello.lua"));

	end ();
});

app.get ("lua.haml", (req, res, end) => {
	var writer = new DataOutputStream (res.body);
	writer.put_string (lua.run ("examples/app/haml.lua"));
	end ();
});


// Ctpl template rendering
app.get ("ctpl/<foo>/<bar>", (req, res, end) => {
	var tpl = new View.from_string ("""
	   <p>hello {foo}</p>
	   <p>hello {bar}</p>
	   <ul>
		 {for el in strings}
		   <li>{el}</li>
		 {end}
	   </ul>
	""");

	tpl.push_string ("foo", req.params["foo"]);
	tpl.push_string ("bar", req.params["bar"]);
	tpl.push_strings ("strings", {"a", "b", "c"});
	tpl.push_int ("int", 1);

	tpl.stream (res.body);
	end ();
});

// memcached
app.get ("memcached/get/<key>", (req, res, end) => {
	var value = mcd.get (req.params["key"]);
	var writer = new DataOutputStream (res.body);
	writer.put_string (value);
	end ();
});

// TODO: rewrite using POST
app.get ("memcached/set/<key>/<value>", (req, res, end) => {
	var writer = new DataOutputStream (res.body);
	if (mcd.set (req.params["key"], req.params["value"])) {
		writer.put_string ("Ok! Pushed.");
	} else {
		writer.put_string ("Fail! Not Pushed...");
	}
	end ();
});

// scoped routing
app.scope ("admin", (adm) => {
	// matches /admin/fun
	adm.scope ("fun", (fun) => {
		// matches /admin/fun/hack
		fun.get ("hack", (req, res, end) => {
			var time = new DateTime.now_utc ();
			var writer = new DataOutputStream (res.body);
			res.headers.set_content_type ("text/plain", null);
			writer.put_string ("It's %s around here!\n".printf (time.format ("%H:%M")));
			end ();
		});
		// matches /admin/fun/heck
		fun.get ("heck", (req, res, end) => {
			var writer = new DataOutputStream (res.body);
			res.headers.set_content_type ("text/plain", null);
			writer.put_string ("Wuzzup!");
			end ();
		});
	});
});

app.get ("next", (req, res, end, next) => {
	next ();
});

app.get ("next", (req, res, end) => {
	res.body.write ("Matched by the next route in the queue.".data);
	end ();
});

// serve static resource using a path route parameter
app.get ("static/<path:resource>.<any:type>", (req, res, end) => {
	var resource = req.params["resource"];
	var type     = req.params["type"];
	var contents = new uint8[128];
	var path     = "/static/%s.%s".printf (resource, type);
	bool uncertain;

	try {
		var lookup = resources_lookup_data (path, ResourceLookupFlags.NONE);

		// set the content-type based on a good guess
		res.headers.set_content_type (ContentType.guess (path, lookup.get_data (), out uncertain), null);

		if (uncertain)
			warning ("could not infer content type of file %s.%s with certainty".printf (resource, type));

		var file = resources_open_stream (path, ResourceLookupFlags.NONE);

		// transfer the file
		res.body.splice_async.begin (file, OutputStreamSpliceFlags.CLOSE_SOURCE, Priority.DEFAULT, null, (obj, result) => {
			var size = res.body.splice_async.end (result);
			end ();
		});
	} catch (Error e) {
		throw new ClientError.NOT_FOUND (e.message);
	}
});

app.get ("redirect", (req, res, end) => {
	throw new Redirection.MOVED_TEMPORARILY ("http://example.com");
});

app.get ("not-found", (req, res, end) => {
	throw new ClientError.NOT_FOUND ("the given URL was not found");
});

app.method (VSGI.Request.GET, "custom-method", (req, res, end) => {
	var writer = new DataOutputStream (res.body);
	writer.put_string (req.method);
	end ();
});

app.regex (VSGI.Request.GET, /custom-regular-expression/, (req, res, end) => {
	var writer = new DataOutputStream (res.body);
	writer.put_string ("This route was matched using a custom regular expression.");
	end ();
});

app.matcher (VSGI.Request.GET, (req) => { return req.uri.get_path () == "/custom-matcher"; }, (req, res, end) => {
	var writer = new DataOutputStream (res.body);
	writer.put_string ("This route was matched using a custom matcher.");
	end ();
});

var api = new Router ();

api.get ("repository/<name>", (req, res, end) => {
	var name = req.params["name"];
	res.body.write (name.data);
	end ();
});

// delegate all other GET requests to a subrouter
app.get ("<any:path>", api.handle);

app.status (Soup.Status.NOT_FOUND, (req, res, end) => {
	res.status = Soup.Status.NOT_FOUND;
	var template = new View.from_stream (resources_open_stream ("/templates/404.html", ResourceLookupFlags.NONE));
	template.environment.push_string ("path", req.uri.get_path ());
	template.stream (res.body);
	end ();
});

new Server (app).run ({"app", "--port", "3003"});
