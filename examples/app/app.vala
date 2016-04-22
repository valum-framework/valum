/*
 * This file is part of Valum.
 *
 * Valum is free software: you can redistribute it and/or modify it under the
 * terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) any
 * later version.
 *
 * Valum is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with Valum.  If not, see <http://www.gnu.org/licenses/>.
 */

using Valum;
using Valum.ContentNegotiation;
using Valum.ServerSentEvents;
using VSGI;

public HandlerCallback respond_with_text (RespondWithCallback<string> respond) {
	return respond_with<string> (respond, (req, res, next, ctx, text) => {
		return res.expand_utf8 (text);
	});
}

var app = new Router ();

app.use (basic ());
app.use (decode ());

app.use ((req, res, next) => {
	res.headers.append ("Server", "Valum/1.0");
	HashTable<string, string>? @params = new HashTable<string, string> (str_hash, str_equal);
	@params["charset"] = "utf-8";
	res.headers.set_content_type ("text/html", @params);
	return next ();
});

app.use (status (Soup.Status.NOT_FOUND, (req, res, next, context, err) => {
	var template = new View.from_stream (resources_open_stream ("/templates/404.html", ResourceLookupFlags.NONE));
	template.environment.push_string ("message", err.message);
	res.status = Soup.Status.NOT_FOUND;
	HashTable<string, string> @params;
	res.headers.get_content_type (out @params);
	res.headers.set_content_type ("text/html", @params);
	return template.to_stream (res.body);
}));

app.get ("/", (req, res, next) => {
	var template = new View.from_resources ("/templates/home.html");
	return template.to_stream (res.body);
});

app.get ("/async", (req, res) => {
	res.expand_utf8_async.begin ("Hello world!");
	return true;
});

app.get ("/gzip", sequence ((req, res, next) => {
	res.headers.replace ("Content-Encoding", "gzip");
	res.convert (new ZlibCompressor (ZlibCompressorFormat.GZIP));
	return next ();
}, (req, res) => {
	var template = new View.from_resources ("/templates/home.html");
	return template.to_stream (res.body);
}));

// replace 'Content-Type' for 'text/plain'
app.use ((req, res, next) => {
	HashTable<string, string>? @params;
	res.headers.get_content_type (out @params);
	res.headers.set_content_type ("text/plain", @params);
	return next ();
});

app.get ("/headers", (req, res) => {
	var headers = new StringBuilder ();
	req.headers.foreach ((name, header) => {
		headers.append_printf ("%s: %s\n", name, header);
	});
	return res.expand_utf8 (headers.str);
});

app.get ("/query", (req, res) => {
	if (req.query == null) {
		return res.expand_utf8 ("null");
	} else {
		var query = new StringBuilder ();
		req.query.foreach ((k, v) => {
			query.append_printf ("%s: %s\n", k, v);
		});
		return res.expand_utf8 (query.str);
	}
});

app.get ("/cookies", (req, res) => {
	if (req.cookies == null) {
		return res.expand_utf8 ("null");
	} else {
		var cookies = new StringBuilder ();
		foreach (var cookie in req.cookies) {
			cookies.append_printf ("%s: %s\n", cookie.name, cookie.value);
		}
		return res.expand_utf8 (cookies.str);
	}
});

app.scope ("/cookie", (inner) => {
	inner.get ("/<name>", (req, res, next, context) => {
		foreach (var cookie in req.cookies)
			if (cookie.name == context["name"].get_string ())
				return res.expand_utf8 ("%s\n".printf (cookie.value));
		return res.end ();
	});

	inner.post ("/<name>", (req, res, next, context) => {
		var cookie = new Soup.Cookie (context["name"].get_string (), req.flatten_utf8 (), "0.0.0.0", "/", 60);
		res.headers.append ("Set-Cookie", cookie.to_set_cookie_header ());
		return res.end ();
	});
});

app.scope ("/urlencoded-data", (inner) => {
	inner.get ("", (req, res) => {
		res.headers.set_content_type ("text/html", null);
		return res.expand_utf8 (
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
	});

	inner.post ("", (req, res) => {
		var post = Soup.Form.decode (req.flatten_utf8 ());
		var builder = new StringBuilder ();

		post.foreach ((k, v) => {
			builder.append_printf ("%s: %s\n", k, v);
		});

		return res.expand_utf8 (builder.str);
	});
});

app.get ("/tee", (req, res) => {
	var buffer = new MemoryOutputStream (null, realloc, free);
	res.tee (buffer);
	try {
		return res.expand_utf8 ("Hello world!");
	} finally {
		message ("Produced '%s'.", (string) buffer.data);
	}
});

app.scope ("/multipart", () => {
	app.use (accept ("text/html"));

	app.get ("", (req, res) => {
		return res.expand_utf8 ("""<!DOCTYPE html>
		<html>
		  <head>
		    <title></title>
		  </head>
		  <body>
		    <p>This demo shows how to handle <code>multipart/form-data</code> payloads.</p>
		    <form method="post" enctype="multipart/form-data">
		      <input name="filename" placeholder="Document Name">
		      <input type="file" name="document">
		      <input type="submit">
		    </form>
		  </body>
		</html>""");
	});

	app.post ("", multipart ((req, res, next, ctx, mis) => {
		var i = 1;
		Soup.MessageHeaders? part_headers;
		while (mis.next_part (out part_headers)) {
			res.append_utf8 ("<h3>Part #%d</h3>".printf (i++));
			res.append_utf8 ("<pre>");
			res.body.splice (mis, OutputStreamSpliceFlags.NONE);
			res.append_utf8 ("</pre>");
		}
		return res.end ();
	}));
});

// hello world! (compare with Node.js!)
app.get ("/hello", respond_with_text (() => {
	return "Hello world!";
}));

app.get ("/hello/", (req, res) => {
	return res.expand_utf8 ("Hello world!");
});

app.rule (Method.GET | Method.POST, "/get-and-post", (req, res) => {
	return res.expand_utf8 ("Matches GET and POST");
});

app.rule (Method.GET, "/custom-method", (req, res) => {
	return res.expand_utf8 (req.method);
});

app.get ("/hello/<id>", (req, res, next, context) => {
	return res.expand_utf8 ("hello %s!".printf (context["id"].get_string ()));
});

app.get ("/users/<int:id>(/<action>)?", (req, res, next, context) => {
	var id     = context["id"].get_string ();
	var test   = "action" in context ? context["action"].get_string () : "index";
	var writer = new DataOutputStream (res.body);

	writer.put_string (@"id\t=> $id\n");
	writer.put_string (@"action\t=> $test");

	return true;
});

app.register_type ("permutations", /abc|acb|bac|bca|cab|cba/);

app.get ("/custom-route-type/<permutations:p>", (req, res, next, context) => {
	return res.expand_utf8 (context["p"].get_string ());
});

app.get ("/trailing-slash/?", (req, res) => {
	if (req.uri.get_path ().has_suffix ("/")) {
		return res.expand_utf8 ("It has it!");
	} else {
		return res.expand_utf8 ("It does not!");
	}
});

app.regex (Method.GET, /\/custom-regular-expression/, (req, res) => {
	return res.expand_utf8 ("This route was matched using a custom regular expression.");
});

app.path (Method.GET, "/exact-path", (req, res) => {
	return res.expand_utf8 ("This route was matched using a path.");
});

app.matcher (Method.GET, (req) => { return req.uri.get_path () == "/custom-matcher"; }, (req, res) => {
	return res.expand_utf8 ("This route was matched using a custom matcher.");
});

// scoped routing
app.scope ("/admin", (adm) => {
	// matches /admin/fun
	adm.scope ("/fun", (fun) => {
		// matches /admin/fun/hack
		fun.get ("/hack", (req, res) => {
			var time = new DateTime.now_utc ();
			return res.expand_utf8 ("It's %s around here!\n".printf (time.format ("%H:%M")));
		});
		// matches /admin/fun/heck
		fun.get ("/heck", (req, res) => {
			return res.expand_utf8 ("Wuzzup!");
		});
	});
});

app.get ("/redirect", (req, res) => {
	throw new Redirection.MOVED_TEMPORARILY ("http://example.com");
});

app.get ("/not-found", (req, res) => {
	throw new ClientError.NOT_FOUND ("This status were thrown and handled by a status handler.");
});

var api = new Router ();

api.get ("/<name>", (req, res, next, context) => {
	var name = context["name"].get_string ();
	return res.expand_utf8 (name);
});

// delegate all requests which path starts with '/repository'
app.use (subdomain ("api", api.handle));
app.use (basepath ("/repository", api.handle));

app.get ("/next", (req, res, next) => {
	return next ();
});

app.get ("/next", (req, res) => {
	return res.expand_utf8 ("Matched by the next route in the queue.");
});

app.get ("/sequence", sequence ((req, res, next) => {
	return next ();
}, (req, res) => {
	return res.expand_utf8 ("Hello world!");
}));

app.get ("/state", (req, res, next, context) => {
	context["state"] = "I have been passed!";
	return next ();
});

app.get ("/state", (req, res, next, context) => {
	return res.expand_utf8 (context["state"].get_string ());
});

// Ctpl template rendering
app.get ("/ctpl/<foo>/<bar>", (req, res, next, context) => {
	var tpl = new View.from_string ("""
	   <p>hello {foo}</p>
	   <p>hello {bar}</p>
	   <ul>
		 {for el in strings}
		   <li>{el}</li>
		 {end}
	   </ul>
	""");

	tpl.push_string ("foo", context["foo"].get_string ());
	tpl.push_string ("bar", context["bar"].get_string ());
	tpl.push_strings ("strings", {"a", "b", "c"});
	tpl.push_int ("int", 1);

	res.headers.set_content_type ("text/html", null);
	return tpl.to_stream (res.body);
});

// serve static resource using a path route parameter
app.get ("/static/<path:path>", Static.serve_from_file (File.new_for_uri ("resource://static/"), Static.ServeFlags.ENABLE_ETAG));

app.get ("/server-sent-events", stream_events ((req, send) => {
	send (null, "now!");
	GLib.Timeout.add_seconds (5, () => {
		try {
			send (null, "later!");
		} catch (Error err) {
			warning (err.message);
		}
		return false;
	});
}));

app.get ("/negotiate", accept ("application/json, text/xml", (req, res, next, ctx, content_type) => {
	switch (content_type) {
		case "application/json":
			return res.expand_utf8 ("{\"a\":\"b\"}");
		case "text/xml":
			return res.expand_utf8 ("<a>b</a>");
		default:
			assert_not_reached ();
	}
}));

app.get ("/negotiate-charset", accept_charset ("utf-8", (req, res) => {
	return res.expand_utf8 ("Héllo world!");
}));

app.get ("/negotiate-encoding", accept_encoding ("gzip, deflate", (req, res, next, stack, encoding) => {
	return res.expand_utf8 ("Hello world! (compressed with %s)".printf (encoding));
}));

app.get ("/auth", authenticate (new BasicAuthentication (""), (a) => {
	return a.challenge_with_password ("1234");
}, (req, res, next, ctx, username) => {
	return res.expand_utf8 ("Hello %s!".printf (username));
}));

Server.@new ("http", handler: app).run ();
