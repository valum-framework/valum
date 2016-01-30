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
using Valum.Static;
using VSGI.FastCGI;

public static int main (string[] args) {
	var app = new Router ();

	// default route
	app.get ("", (req, res) => {
		res.body.write_all ("Hello world!".data, null);
	});

	app.get ("random/<int:size>", (req, res) => {
		var size   = int.parse (req.params["size"]);
		var writer = new DataOutputStream (res.body);

		for (; size > 0; size--) {
			// write byte to byte
			writer.put_uint32 (Random.next_int ());
		}
	});

	app.get (null, serve_from_path (File.new_for_path (""), ServeFlags.PRODUCE_X_SENDFILE));

	app.get ("<any:path>", (req, res) => {
		res.status = 404;

		var writer = new DataOutputStream (res.body);
		writer.put_string ("404 - Not found");
	});

	return new Server ("org.valum.example.FastCGI", app.handle).run (args);
}
