using GLib;

/**
 * VSGI is an set of abstraction and implementations used to build generic web
 * application in Vala.
 *
 * It is minimalist and relies on libsoup, a good and stable HTTP library.
 *
 * Two implementation are available: libsoup built-in Soup.Server and FastCGI.
 * The latter integrates with pretty much any web server.
 */
[CCode (gir_namespace = "VSGI", gir_version = "0.1")]
namespace VSGI {
	/**
	 * Application that handles a pair of {@link VSGI.Request} and
	 * {@link VSGI.Response}.
	 *
	 * @since 0.1
	 */
	public interface Application : Object {

		/**
		 * Process a pair of request and response.
		 *
		 * Blocks until the response have been fully processed.
		 *
		 * @since 0.1
		 *
		 * @param req request providen to the application by a
		 *            {@link VSGI.Server}
		 * @param res response where the application should produce its output
		 */
		public abstract void handle (Request req, Response res);
	}
}
