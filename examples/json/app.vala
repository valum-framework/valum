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
using VSGI.Soup;

var app = new Router ();

app.get ("", (req, res) => {
	var builder   = new Json.Builder ();
	var generator = new Json.Generator ();

	builder.begin_object ();

	builder.set_member_name ("latitude");
	builder.add_double_value (5.40000123);

	builder.set_member_name ("longitude");
	builder.add_double_value (56.34318);

	builder.set_member_name ("elevation");
	builder.add_double_value (2.18);

	builder.end_object ();

	generator.root   = builder.get_root ();
	generator.pretty = true;

	res.headers.set_content_type ("application/json", null);

	generator.to_stream (res.body);
});

new Server ("org.valum.example.JSON", app.handle).run ({"app", "--all"});
