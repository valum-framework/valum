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

/**
 * Valum is a web micro-framework written in Vala.
 */
[CCode (gir_namespace = "Valum", gir_version = "0.3")]
namespace Valum {

	/**
	 * Loads {@link Route} instances on a provided router.
	 *
	 * This is used for scoping and as a general definition for callback
	 * taking a {@link Router} as parameter like modules.
	 *
	 * @since 0.0.1
	 */
	public delegate void LoaderCallback (Router router);

	/**
	 * Match the request and populate the {@link Valum.Context}.
	 *
	 * This is expected to be *very* fast and thus, no blocking operation must
	 * be performed. If necessary, it is preferable to use a
	 * {@link Valum.HandlerCallback} and invoke the 'next' continuation when ready.
	 *
	 * @since 0.1
	 *
	 * @param req     request being matched
	 * @param context context which may be initial or derive from a parent
	 *
	 * @return 'true' if the request is matched, otherwise 'false'
	 */
	public delegate bool MatcherCallback (Request req, Context context);

	/**
	 * Handle a pair of request and response.
	 *
	 * @since 0.0.1
	 *
	 * @throws Error callback are free to raise any error
	 *
	 * @param req     request being handled
	 * @param res     response to send back to the requester
	 * @param next    continuation to keep routing
	 * @param context routing context which parent is the context of the
	 *                preceeding 'next' invocation or initialized by the
	 *                first {@link Valum.MatcherCallback}
	 *
	 * @return 'true' if the request has been or will eventually be handled,
	 *         otherwise 'false'
	 */
	public delegate bool HandlerCallback (Request      req,
	                                      Response     res,
	                                      NextCallback next,
	                                      Context      context) throws Error;

	/**
	 * Define a type of {@link Valum.HandlerCallback} that forward a generic
	 * value.
	 *
	 * @since 0.3
	 */
	public delegate bool ForwardCallback<T> (Request      req,
	                                         Response     res,
	                                         NextCallback next,
	                                         Context      context,
	                                         T            @value) throws Error;

	/**
	 * Continuation passed in a {@link Valum.HandlerCallback} to *keep routing*
	 * both {@link VSGI.Request} and {@link VSGI.Response}.
	 *
	 * Any thrown error will be propagate to the caller found upstream in the
	 * routing.
	 *
	 * @since 0.1
	 */
	public delegate bool NextCallback () throws Informational,
	                                            Success,
	                                            Redirection,
	                                            ClientError,
	                                            ServerError,
	                                            Error;
}
