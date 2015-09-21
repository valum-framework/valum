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

	/**
	 * Produce a matching middleware that negates the provided middleware.
	 *
	 * @since 0.3
	 */
	public MatcherCallback not (owned MatcherCallback matcher)  {
		return (req, stack) => { return ! matcher (req, stack); };
	}

	/**
	 * Negociate an 'Accept' header against a provided content type.
	 *
	 * @since 0.3
	 */
	public MatcherCallback accept (string content_type) {
		return (req) => {
			return req.headers.get_list ("Accept").contains (content_type);
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
	public void noop (Request req, Response res, NextCallback next) {
		next (req, res);
	}
}

