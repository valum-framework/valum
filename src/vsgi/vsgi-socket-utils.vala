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

/**
 * Utilities for {@link GLib.Socket} and the related.
 */
namespace VSGI.SocketUtils
{
	/**
	 * Obtain a {@link GLib.SocketAddress} from an URI.
	 *
	 * If 'unix' is specified as scheme, a {@link GLib.UnixSocketAddress} will
	 * be returned. Otherwise, it is ignored and {@link GLib.InetSocketAddress}
	 * is used.
	 *
	 * @since 0.3
	 */
	public SocketAddress socket_address_from_uri (Soup.URI uri) {
		if (uri.scheme == "unix") {
			return new UnixSocketAddress (uri.path);
		}
		return new InetSocketAddress.from_string (uri.host, uri.port);
	}
}
