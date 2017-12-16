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

/**
 * Class-based middleware to ease the organization of complex applications.
 */
[Version (since = "0.4")]
public abstract class Valum.Middleware : VSGI.Handler {

	[Version (since = "0.4")]
	public abstract bool fire (Request      req,
	                           Response     res,
	                           NextCallback next,
	                           Context      ctx) throws Error;

	public override bool handle (Request req, Response res) throws Error {
		return fire (req, res, () => { return true; }, new Context ());
	}
}
