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
	 * Produce a matching middleware that negates the provided middleware.
	 *
	 * @since 0.3
	 */
	public MatcherCallback not (owned MatcherCallback matcher)  {
		return (req, stack) => { return ! matcher (req, stack); };
	}

	/**
	 * Produce a matching middleware that consist of the conjunction of
	 * passed matchers.
	 *
	 * @since 0.3
	 */
	public MatcherCallback and (owned MatcherCallback left, owned MatcherCallback right) {
		return (req, stack) => {
			return left (req, stack) && right (req, stack);
		};
	}

	/**
	 * Produce a matching middleware that consist of the disjunction of
	 * passed matchers.
	 * @since 0.3
	 */
	public MatcherCallback or (owned MatcherCallback left, owned MatcherCallback right) {
		return (req, stack) => {
			return left (req, stack) || right (req, stack);
		};
	}

	/**
	 * Noop handling middleware that simply forwards the request and response
	 * to the next handling middleware.
	 *
	 * It mainly serve as a default value and since it is optimized away by most
	 * functions, so it's always better using it than skipping manually.
	 *
	 * @since 0.3
	 */
	public void noop (Request req, Response res, NextCallback next) throws Error {
		next (req, res);
	}
}

