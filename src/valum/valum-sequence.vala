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

namespace Valum {

	[Version (since = "0.4")]
	public class Sequence : Middleware {

		[Version (since = "0.4")]
		public SList<Middleware> middlewares { get; owned construct; }

		[Version (since = "0.4")]
		public Sequence (Middleware a, ...) {
			this.from_valist (va_list ());
			middlewares.prepend (a);
		}

		[Version (since = "0.4")]
		public Sequence.from_valist (va_list args) {
			Object (middlewares: new SList<Middleware> ());
			for (var arg = args.arg<Middleware?> (); arg != null;) {
				middlewares.prepend (arg);
			}
			middlewares.reverse ();
		}

		private bool _fire (SList<Middleware> middlewares, Request req, Response res, NextCallback next, Context ctx) throws Error {
			if (middlewares == null) {
				return next ();
			} else {
				return middlewares.data.fire (req, res, () => {
					return _fire (middlewares.next, req, res, next, ctx);
				}, ctx);
			}
		}

		public override bool fire (Request req, Response res, NextCallback next, Context ctx) throws Error {
			return _fire (middlewares, req, res, next, ctx);
		}
	}

	/**
	 * Produce a handler sequence of 'a' and 'b'.
	 */
	[Version (since = "0.3")]
	public HandlerCallback sequence (owned HandlerCallback a, owned HandlerCallback b) {
		return new Sequence (Middleware.from_handler_callback (a), Middleware.from_handler_callback (b)).fire;
	}
}
