Valum Framework. Relax :)
=========================
Valum is a web micro-framework based on libsoup and entirely written in the
[Vala](https://wiki.gnome.org/Projects/Vala) language.

Valum ships with a [Ctpl](http://ctpl.tuxfamily.org/), a lightweight and simple
temlating engine.

Features
--------

 - router with scoping and typed parameters
 - simple Request-Response based on Soup Message
 - basic templating engine [Ctpl](http://ctpl.tuxfamily.org/)

Quickstart
----------

Debian/Ubuntu
```bash
apt-get install -y git-core build-essential valac libgee-0.8-dev \
                   libsoup2.4-dev libjson-glib-dev memcached libmemcached-dev \
                   libluajit-5.1-dev libctpl-dev
```

Fedora
```bash
sudo yum install git python vala libgee-devel libsoup-devel libjson-glib-devel \
                 libctpl-devel libmemcached-devel luajit-devel
```

You may either clone or download one of our
[releases](https://github.com/antono/valum/releases) from GitHub
```bash
git clone git://github.com/antono/valum.git && cd valum
```

We use the waf build system, so all you need is Python installed
```bash
./waf configure
./waf build
```

Valum can be installed system-wide and used as a shared library, the sample
application should be in your `$PATH`
```bash
./waf install
valum
```

Or you can run the sample application from the `build` folder
```bash
./build/valum
```

Visit [http://localhost:3003/](http://localhost:3003/) on your favourite web
browser.

Examples
--------

Setup application
```vala
using Soup;
using Valum;

var app = new Router();

app.get('', (req, res) => {
    res.append("Hello world!");
});

var server = new Soup.Server(Soup.SERVER_SERVER_HEADER, Valum.APP_NAME);

// bind the application to the server
server.add_handler("/", app.request_handler);

try {
	server.listen_local(3000, Soup.ServerListenOptions.IPV4_ONLY);
} catch (Error error) {
	stderr.printf("%s.\n", error.message);
}
```

GET request
```vala
app.get("hello", (req, res) => {
  res.status = 200;
  res.mime = "text/plain";
  res.headers.append("Hello", "Browser");
  res.append("Hello World!");
});
```

POST request (not implemented)
```vala
app.post("hello", (req, res) => {
    var username = req.post["username"];
    var password = req.post["password"];
    res.append("You have been authenticated!");
});
```

Route scoping
```vala
// GET /admin/user/11
// GET /admin/user/antono
app.scope("admin", (admin) => {
  admin.get("user/:id", (req, res) => {
    var id = req.params["id"];
    res.append(@"User id is $id");
  });
});
```

Scripting languages!
--------------------

Embedded Lua
```vala
var app = new Valum.Router();
var lua = new Valum.Script.Lua();

// GET /lua
app.get("lua", (req, res) => {
  res.append(lua.eval("""
    require "markdown"
    return markdown('## Hello from lua.eval!')
  """));

  res.append(lua.run("app/hello.lua"));
});
```

This code works with either Lua or LuaJIT depending
on `--pkg` option in `Makefile`. See ./vapi/lua[jit].vapi for
details.

We are going to implement simplier syntax for lua scripts:

Vala code:
```vala
app.get("lua.html", app.lua("hello"));
```

Lua code:
```lua
-- VALUM_ROOT/scripts/hello.lua
require 'markdown'
return markdown("# Hello from Lua!!!")
-- returned value will be appended to response body
```

Resulted html:
```html
<h1> Hello from Lua!!! </h1>
```

Embedded scheme! (TODO)
```vala
app.get("hello.scm", app.scm("hello"));
```

Scheme code:

```scheme
;; VALUM_ROOT/scripts/hello.scm
(+ 1 2 3)
;; returned value will be casted to string
;; and appended to response body
```

Persistance
-----------

Memcached
```vala
var mc = new Valum.NoSQL.Memcached();

// GET /hello
app.get("hello", (req, res) => {
  var value = mc.get("hello");
  res.append(value);
  mc.set("hello", @"Updated $value");
});
```

Redis (TODO)

We need vapi for hiredis: https://github.com/antirez/hiredis

```vala
var redis = new Valum.NoSQL.Redis();

app.get("hello", (req, res) => {
  var value = redis.get("hello");
  res.append(value);
  redis.set("hello", @"Updated $value");
});
```

MongoDB (TODO)

This is not yet implemented. But mongo client for
vala is on the way: https://github.com/chergert/mongo-glib

```vala
var mongo = new Valum.NoSQL.Mongo();

// GET /hello.json
app.get("hello.json", (req, res) => {
  res.mime = "application/json";
  res.append(mongo.find("hello"));
});
```

Contributing
------------

 1. fork repository
 2. pick one task from TODO.md or GitHub issues
 3. and add your name after it in TODO
 4. code
 5. make pull request with your amazing changes
 6. enjoy :)

Discussions and help
--------------------

 - Mailing list: [vala-list](https://mail.gnome.org/mailman/listinfo/vala-list).
 - IRC channel: #vala at irc.gimp.net
 - [Google+ page for Vala](https://plus.google.com/115393489934129239313/)
 - Issues on [GitHub](https://github.com/antono/valum/issues)
