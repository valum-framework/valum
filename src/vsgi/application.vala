/**
 * VSGI is an set of abstraction and implementations used to build generic web
 * application in Vala.
 *
 * It is minimalist and relies on libsoup, a good and stable HTTP library.
 *
 * Two implementation are planned: Soup.Server and FastCGI. The latter
 * integrates with pretty much any web server.
 */
[CCode (gir_namespace = "VSGI", gir_version = "0.1")]
namespace VSGI {

	/**
	 * VSGI application handling a {@link Request} and producing a
	 * {@link Response}.
	 *
	 * A working application is easily defined when combined with a
	 * {@link Server} implementation.
	 *
	 * new SoupServer ((req, res) => {
	 *     res.write ("Hello world!".data);
	 * });
	 *
	 * @since 0.1
	 *
	 * @param Request  req request providen to the application by a
	 *                     VSGI.Server
	 * @param Response res response where the application should produce its
	 *                     output
	 */
	public delegate void Application (Request req, Response res);
}
