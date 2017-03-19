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

using VSGI;

public class App : Handler  {

	public override async bool handle_async (Request req, Response res) throws Error {
		res.headers.set_content_type ("text/plain", null);
		return yield res.expand_utf8_async ("Hello world!");
	}
}

public int main (string[] args) {
	return Server.@new ("http", handler: new App ()).run (args);
}
