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
	 * Respond to the passed request and context with a value.
	 */
	[Version (since = "0.4")]
	public delegate T RespondWithCallback<T> (Request req, Context ctx) throws Error;

	/**
	 * Produce a callback that responds to the incoming request with a value.
	 *
	 * Typically, the forward callback is implemented once so that handlers can
	 * be simply defined by a function that return a value that fits the generic
	 * type.
	 */
	[Version (since = "0.4")]
	public HandlerCallback respond_with<T> (owned RespondWithCallback<T> respond, owned ForwardCallback<T> forward) {
		return (req, res, next, ctx) => {
			return forward (req, res, next, ctx, respond (req, ctx));
		};
	}
}
