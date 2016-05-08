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
 * VSGI is an set of abstraction and implementations used to build generic web
 * application in Vala.
 *
 * It is minimalist and relies on libsoup-2.4, a good and stable HTTP library.
 *
 * Two implementation are available: libsoup built-in Soup.Server and FastCGI.
 * The latter integrates with pretty much any web server.
 */
[CCode (gir_namespace = "VSGI", gir_version = "0.2")]
namespace VSGI {

	/**
	 * Process a pair of {@link VSGI.Request} and {@link VSGI.Response}.
	 *
	 * The end continuation must be invoked when the application processing
	 * finishes. It may be invoked in an asynchronous context even after the
	 * callback returns to the callee.
	 *
	 * @since 0.2
	 *
	 * @param req a resource being requested
	 * @param res the response to that request
	 * @return true if the request was or will eventually be fully handled
	 */
	public delegate bool ApplicationCallback (Request req, Response res) throws Error;
}
