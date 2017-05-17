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

[Version (since = "0.4")]
public abstract class Valum.ForwardMiddleware<T> : Valum.Middleware {

	private class FromForwardCallback<T> : ForwardMiddleware<T> {

		private ForwardCallback<T> _forward;

		public FromForwardCallback (owned ForwardCallback<T> callback) {
			_forward = callback;
		}

		public override bool fire_with (Request req, Response res, NextCallback next, Context ctx, T @value) throws Error {
			return _forward (req, res, next, ctx, @value);
		}
	}

	public static ForwardMiddleware<T> from_forward_callback<T> (owned ForwardCallback<T> callback) {
		return new FromForwardCallback<T> (callback);
	}

	public virtual bool fire_with (Request req, Response res, NextCallback next, Context ctx, T @value) throws Error {
		return fire (req, res, next, ctx); /* discard the value */
	}

	public virtual async bool fire_with_async (Request req, Response res, NextCallback next, Context ctx, T @value) throws Error {
		return fire_with (req, res, next, ctx, @value);
	}
}
