using Lua;
using Valum;
using VSGI.Soup;

var app = new Router ();
var vm  = new LuaVM ();

vm.open_libs ();

app.get ("", (req, res) => {
	vm.do_string ("""
		require "markdown"
		return markdown('## Hello from lua.eval!')""");

	res.body.write_all (vm.to_string (-1).data, null);
});

new Server ("org.valum.example.Lua", app.handle).run ({"app", "--all"});
