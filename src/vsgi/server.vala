namespace VSGI {

	/**
	 * Server that handles a single Application.
	 *
	 * It is the server responsibility to close {@link Request} and
	 * {@link Response} providen to the served {@link Application} if it has not
	 * been done in the {@link Application.handler}.
	 *
	 * @since 0.1
	 */
	public abstract class Server : Object {

		/**
		 * Application handling incoming request.
		 */
		protected VSGI.Application application;

		/**
		 * Creates a new Server that serve a given application.
		 *
		 * @since 0.1
		 *
		 * @param app application served by this server.
		 */
		public Server (VSGI.Application app) {
			this.application = app;
		}

		/**
		 * Start listening on incoming requests.
		 *
		 * @since 0.1
		 */
		public abstract void listen ();
	}
}
