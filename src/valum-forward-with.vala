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

namespace Valum {

	/**
	 * Forward using a provided handler callback.
	 *
	 * This is basically a hack to pass a {@link Valum.HandlerCallback} where a
	 * {@link Valum.ForwardCallback} is expected, discarding the forwarded
	 * value.
	 */
	[Version (since = "0.3")]
	public ForwardCallback<T> forward_with<T> (owned HandlerCallback handle) {
		return (req, res, next, ctx, @value) => {
			return handle (req, res, next, ctx);
		};
	}
}
