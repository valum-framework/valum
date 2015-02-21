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
	 * Application that handles {@link Request} and produce {@link Response}.
	 *
	 * @since 0.1
	 */
	public interface Application : GLib.Object {

		/**
		 * Signal handling a {@link Request} and producing a {@link Response}.
		 *
		 * The rationale behind using a signal is that it allows binding of
		 * callbacks before and after the default handler is executed, which
		 * comes very handy for setup and teardown operations like database
		 * connection.
		 *
		 * @since 0.1
		 *
		 * @param Request  req request providen to the application by a
		 *                     VSGI.Server
		 * @param Response res response where the application should produce its
		 *                     output
		 */
		public virtual signal void handle (Request req, Response res) {}
	}
}
