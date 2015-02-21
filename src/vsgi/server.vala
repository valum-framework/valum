namespace VSGI {

	/**
	 * Server that handles a single {@link VSGI.Application}.
	 *
	 * Once you have initialized a Server instance, start it by calling
	 * {@link Server.run} with the command-line arguments.
	 *
	 * It is the server responsibility to close {@link Request} and
	 * {@link Response} providen to the served {@link Application} if it has not
	 * been done in {@link Application.handle}.
	 *
	 * @since 0.1
	 */
	public abstract class Server : GLib.Application {

		/**
		 * Application being served.
		 *
		 * @since 0.1
		 */
		public VSGI.Application application { construct; get; }
	}
}
