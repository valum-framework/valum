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
[CCode (gir_namespace = "Valum", gir_version = "0.2")]
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
	 * Match the request and populate the initial {@link Valum.Context}.
	 *
	 * @since 0.1
	 *
	 * @param req     request being matched
	 * @param context initial context
	 */
	public delegate bool MatcherCallback (Request req, Context context);

	/**
	 * Handle a pair of request and response.
	 *
	 * @since 0.0.1
	 *
	 * @throws Informational raise a 1xx informational code
	 * @throws Success       raise a 2xx success code
	 * @throws Redirection   perform a 3xx HTTP redirection
	 * @throws ClientError   trigger a 4xx client error
	 * @throws ServerError   trigger a 5xx server error
	 * @throws Error         any other error which will be handled as a
	 *                       {@link Valum.ServerError.INTERNAL_SERVER_ERROR}
	 *
	 * @param req     request being handled
	 * @param res     response to send back to the requester
	 * @param next    keep routing
	 * @param context routing context which parent is the context of the
	 *                preceeding 'next' invocation or initialized by the
	 *                first {@link Valum.MatcherCallback}
	 */
	public delegate bool HandlerCallback (Request req,
	                                      Response res,
	                                      NextCallback next,
	                                      Context context) throws Informational,
	                                                              Success,
	                                                              Redirection,
	                                                              ClientError,
	                                                              ServerError,
	                                                              Error;

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
	 * It is also used as a generic continuation that propagates a thrown status
	 * code or invoke processing in the {@link Valum.Router} context.
	 *
	 * The passed {@link VSGI.Request} and {@link VSGI.Response} objects can be
	 * optionally filtered using {@link VSGI.FilteredRequest} and
	 * {@link VSGI.FilteredResponse}.
	 *
	 * See {@link Valum.HandlerCallback} for details on thrown error domains.
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
