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
 */
[CCode (gir_namespace = "VSGI", gir_version = "0.3")]
namespace VSGI {

	/**
	 * Process a pair of {@link VSGI.Request} and {@link VSGI.Response}.
	 *
	 * This delegate describe the signature of a compliant VSGI application. It
	 * is passed to a {@link VSGI.Server} in order to receive request to
	 * process.
	 *
	 * @since 0.2
	 *
	 * @throws Error unrecoverable error condition can be raised and will be
	 *               handled by the implementation
	 *
	 * @param req a resource being requested
	 * @param res the response to that request
	 *
	 * @return 'true' if the request has been or will eventually be handled,
	 *         otherwise 'false'
	 */
	public delegate bool ApplicationCallback (Request req, Response res) throws Error;

	/**
	 * @since 0.3
	 */
	[CCode (has_target = false)]
	public delegate Type ServerInitFunc (TypeModule module);
}
