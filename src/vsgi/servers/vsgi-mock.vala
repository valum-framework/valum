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
using Soup;

[ModuleInit]
public Type server_init (TypeModule type_module) {
	return typeof (VSGI.Mock.Server);
}

/**
 * Mock implementation of VSGI used for testing purposes.
 */
namespace VSGI.Mock {

	/**
	 *
	 */
	public class Server : VSGI.Server {

		private SList<Soup.URI> _uris;

		public override SList<Soup.URI> uris { get { return _uris; } }

		public override void listen (Variant options) throws Error {
			_uris.append (new Soup.URI ("mock://"));
		}

		public override void stop () {
			// nothing to stop
		}
	}
}
