using VSGI;

/**
 * Valum is a web micro-framework written in Vala.
 */
[CCode (gir_namespace = "Valum", gir_version = "0.1")]
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
	 * @param req request being matched
	 */
	public delegate bool MatcherCallback (Request req);

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
	 * @param state propagated state from a preceeding next invocation, it
	 *              remains null if this is the top invocation or no state
	 *              have been propagated
	 */
	public delegate void HandlerCallback (Request req, Response res, NextCallback next, Value? state) throws Informational, Success, Redirection, ClientError, ServerError;

	/**
	 * Keeps routing the {@link VSGI.Request} and {@link VSGI.Response}.
	 *
	 * @since 0.1
	 *
	 * @param state propagated state to the next handler
	 */
	public delegate void NextCallback (Value? state = null) throws Informational, Success, Redirection, ClientError, ServerError;
}
