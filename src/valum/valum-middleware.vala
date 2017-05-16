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
 * Class-based middleware to ease the organization of complex applications.
 */
[Version (since = "0.4")]
public abstract class Valum.Middleware : VSGI.Handler {

	private class FromHandlerCallback : Middleware {

		private HandlerCallback _fire;

		public FromHandlerCallback (owned HandlerCallback fire) {
			_fire = (owned) fire;
		}

		public override bool fire (Request req, Response res, NextCallback next, Context ctx) throws Error {
			return _fire (req, res, next, ctx);
		}
	}

	[Version (since = "0.4")]
	public static Middleware from_handler_callback (owned HandlerCallback callback) {
		return new FromHandlerCallback ((owned) callback);
	}

	[Version (since = "0.4")]
	public virtual bool fire (Request      req,
	                          Response     res,
	                          NextCallback next,
	                          Context      ctx) throws Error
	{
		error ("Either 'fire' or 'fire_async' must be implemented.");
	}

	[Version (since = "0.4")]
	public virtual async bool fire_async (Request req, Response res, NextCallback next, Context ctx) throws Error {
		return fire (req, res, next, ctx);
	}

	[Version (since = "0.4")]
	public override bool handle (Request req, Response res) throws Error {
		return fire (req, res, () => { return true; }, new Context ());
	}

	[Version (since = "0.4")]
	public override async bool handle_async (Request req, Response res) throws Error {
		return yield fire_async (req, res, () => { return true; }, new Context ());
	}
}
