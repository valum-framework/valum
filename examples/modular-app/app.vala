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
using VSGI.HTTP;

var app = new Router ();

app.get ("", (req, res) => {
	res.body.write_all (
	"""
	<!DOCTYPE html>
	<html>
	<body>
	<a href="/user/5">View a wonderful user profile</a>
	<a href="/admin/view">Enter administrative business</a>
	</body>
	</html>
	""".data, null);
});

app.rule (Method.ANY, "user/*", new UserRouter ().handle);
app.rule (Method.ANY, "admin/*", new AdminRouter ().handle);

new Server ("org.valum.example.ModularApp", app.handle).run ();
