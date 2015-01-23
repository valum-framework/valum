namespace VSGI {

	public const string APP_NAME = "VSGI";

	/**
	 * Application that handles Request and produce Response.
	 */
	public interface Application : Object {

		/**
		 * Signal handling a Request and producing a Response.
		 *
		 * The rationale behind using a signal is that it allows binding of
		 * callbacks before and after the default handler is executed, which
		 * comes very handy for setup and teardown operations like database
		 * connection.
		 *
		 * @param Request  req request providen to the application by a
		 *                     VSGI.Server
		 * @param Response res response where the application should produce its
		 *                     output
		 */
		public virtual signal void handler (Request req, Response res) {}
	}
}
