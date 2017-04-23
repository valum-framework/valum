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

using GLib;
using VSGI;

/**
 * Middleware wrapping a {@link HandlerCallback}.
 */
[Version (since = "0.4")]
public class Valum.CallbackMiddleware : Middleware {

	private HandlerCallback _fire;

	[Version (since = "0.4")]
	public CallbackMiddleware (owned HandlerCallback fire) {
		_fire = (owned) fire;
	}

	public override bool fire (Request req, Response res, NextCallback next, Context ctx) throws Error {
		return _fire (req, res, next, ctx);
	}
}
