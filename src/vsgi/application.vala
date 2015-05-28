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
		 * End the processing of the {@link VSGI.Application}.
		 *
		 * This delegate is generally provided by the server implementation to free
		 * resources related to a client request.
		 *
		 * @since 0.2
		 */
		public delegate void EndCallback ();

		/**
		 * Process a pair of request and response.
		 *
		 * @since 0.1
		 *
		 * @param req request representing a request resource
		 * @param res response
		 * @param end end the processing of the client request
		 */
		public abstract void handle (Request req, Response res, EndCallback end);
	}
}
