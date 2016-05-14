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

namespace Valum {

	/**
	 * Route supporting the asterisk '*' path.
	 *
	 * @since 0.3
	 */
	public class AsteriskRoute : Route {

		public AsteriskRoute (Method method, owned HandlerCallback handler) {
			Object (method: method);
			_fire = (owned) handler;
		}

		public override bool match (Request req, Context ctx) {
			return "*" == req.uri.get_path ();
		}

		private HandlerCallback _fire;

		public override bool fire (Request req, Response res, NextCallback next, Context ctx) throws Error {
			return _fire (req, res, next, ctx);
		}
	}
}
