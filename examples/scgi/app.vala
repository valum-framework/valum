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
using VSGI;

public int main (string[] args) {
	var app = new Router ();

	app.get ("/", (req, res) => {
		return res.expand_utf8 ("Hello world!", null);
	});

	app.post ("/", (req, res) => {
		res.body.splice (req.body, OutputStreamSpliceFlags.NONE);
		return true;
	});

	app.get ("/async", (req, res) => {
		res.expand_utf8_async.begin ("Hello world!", Priority.DEFAULT, null);
		return true;
	});

	return Server.new_with_application ("scgi", "org.valum.example.SCGI", app.handle).run (args);
}
