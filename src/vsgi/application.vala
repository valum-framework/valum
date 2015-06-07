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
[CCode (gir_namespace = "VSGI", gir_version = "0.1")]
namespace VSGI {

	/**
	 * End the processing of the of a {@link VSGI.ApplicationCallback}.
	 *
	 * This delegate define a continuation passed by the {@link VSGI.Server} to
	 * the {@link VSGI.ApplicationCallback} to release resources related to the
	 * request being processed when the latter finishes.
	 *
	 * @since 0.2
	 */
	public delegate void EndCallback ();

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
	 * @param end end the processing of the client request and free resources
	 */
	public delegate void ApplicationCallback (Request req, Response res, EndCallback end);
}
