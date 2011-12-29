var app = new Valum.Router();
var lua = new Valum.Script.Lua();
var tpl = new Valum.View.Tpl();
var mcd = new Valum.NoSQL.Mcached();

mcd.add_server("127.0.0.1", 11211);
app.port = 3000;

tpl.from_string("""
   <p> hello {foo} </p>
   <p> hello {bar} </p>
   <ul>
	 { for el in arr }
	   <li> { el } </li>
	 { end }
   </ul>
""");

app.get("ctpl/:foo/:bar", (req, res) => {

	var arr = new Gee.ArrayList<Value?>();
	arr.add("omg");
	arr.add("typed hell");

	res.vars["foo"] = req.params["foo"];
	res.vars["bar"] = req.params["bar"];
	res.vars["arr"] = arr;
	res.vars["int"] = 1;

	res.append(tpl.render(res.vars));
});


// Just sample to benchmark against node
app.get("node.js.vs.valum", (req, res) => {
	res.mime = "text/plain";
	res.append("Hello world\n");
});


app.get("users/:id/:action", (req, res) => {
	var id   = req.params["id"];
	var test = req.params["test"];
	res.append(@"id => $id<br/>");
	res.append(@"test => $test<br/>");
});

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

app.get("memcached/set/:key/:value", (req, res) => {
	if (mcd.set(req.params["key"], req.params["value"])) {
		res.append("Ok! Pushed.");
	} else {
		res.append("Fail! Not Pushed...");
	}
});

app.get("memcached/get/:key", (req, res) => {
	var value = mcd.get(req.params["key"]);
	res.append(value);
});

// FIXME: Optimize routing...
// for (var i = 0; i < 1000; i++) {
//		print(@"New route /$i\n");
//		var route = "%d".printf(i);
//		app.get(route, (req, res) => { res.append(@"yo 1"); });
// }

app.scope("admin", (adm) => {
	adm.scope("fun", (fun) => {
		fun.get("hack", (req, res) => {
				res.append("no way!");
				res.append("<br/>");
				var time = new DateTime.now_utc();
				res.append(time.format("%H:%M"));
		});
		fun.get("heck", (req, res) => {
				res.append("fuck!");
		});
	});
});

app.get("hello/:id", (req, res) => {
	res.append("yay");
	res.append(req.params["id"]);
	res.send();
});

app.get("yay", (req, res) => {
	res.append("yay");
	res.append("<br/>");
	res.append("hell yeah");
});

app.get("", (req, res) => {
	res.append("<h1> Welcome </h1>");
});


app.listen();
