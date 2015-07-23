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
	 * Match the request and populate the {@link VSGI.Request.params}.
	 *
	 * It is important for a matcher to populate the
	 * {@link VSGI.Request.params} only if it matches the request.
	 *
	 * @since 0.1
	 *
	 * @param req           request being matched
	 * @param initial_stack destination for the initial routing stack
	 */
	public delegate bool MatcherCallback (Request req, Queue<Value?> initial_stack);

	/**
	 * Handle a pair of request and response.
	 *
	 * @since 0.0.1
	 *
	 * @throws Redirection perform a 3xx HTTP redirection
	 * @throws ClientError trigger a 4xx client error
	 * @throws ServerError trigger a 5xx server error
	 *
	 * @param req   request being handled
	 * @param res   response to send back to the requester
	 * @param next  keep routing
	 * @param stack routing stack as altered by the preceeding next invocation
	 *              or initialized by the first {@link Valum.MatcherCallback}
	 */
	public delegate void HandlerCallback (Request req, Response res, NextCallback next, Queue<Value?> stack) throws Informational, Success, Redirection, ClientError, ServerError;

	/**
	 * Continuation passed in a {@link Valum.HandlerCallback} to *keep routing*
	 * both {@link VSGI.Request} and {@link VSGI.Response}.
	 *
	 * It is also used as a generic continuation that propagates a thrown status
	 * code.
	 *
	 * @since 0.1
	 *
	 * @throws Redirection perform a 3xx HTTP redirection
	 * @throws ClientError trigger a 4xx client error
	 * @throws ServerError trigger a 5xx server error
	 */
	public delegate void NextCallback () throws Informational, Success, Redirection, ClientError, ServerError;
}
