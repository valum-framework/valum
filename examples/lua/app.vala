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
