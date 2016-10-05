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

var app       = new Router ();
var memcached = new Memcached.Context.from_configuration ("--SERVER=localhost".data);

app.use (basic ());

app.get ("/<key>", (req, res, next, context) => {
	var key = context["key"].get_string ();

	uint32 flags;
	Memcached.ReturnCode error;
	var data = memcached.get (key.data, out flags, out error);

	switch (error) {
		case Memcached.ReturnCode.SUCCESS:
			return res.expand (data);
		case Memcached.ReturnCode.NOTFOUND:
			throw new ClientError.NOT_FOUND ("The key '%s' was not found.", key);
		default:
			throw new ServerError.INTERNAL_SERVER_ERROR (memcached.strerror (error));
	}
});

app.put ("/<key>", (req, res, next, context) => {
	var key = context["key"].get_string ();

	var error = memcached.set (key.data, req.flatten (), 0, 0);

	switch (error) {
		case Memcached.ReturnCode.SUCCESS:
			throw new Success.CREATED ("/%s", key);
		default:
			throw new ServerError.INTERNAL_SERVER_ERROR (memcached.strerror (error));
	}
});

app.delete ("/<key>", (req, res, next, context) => {
	var key = context["key"].get_string ();

	var error = memcached.delete (key.data, 0);

	switch (error) {
		case Memcached.ReturnCode.SUCCESS:
			throw new Success.NO_CONTENT ("The key '%s' has been successfully deleted.", key);
		case Memcached.ReturnCode.NOTFOUND:
			throw new ClientError.NOT_FOUND ("The key '%s' was not found.", key);
		default:
			throw new ServerError.INTERNAL_SERVER_ERROR (memcached.strerror (error));
	}
});


Server.new_with_application ("http", app.handle).run ({"app", "--all"});
