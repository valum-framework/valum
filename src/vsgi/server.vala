namespace VSGI {

	/**
	 * Server that handles a single Application.
	 */
	public abstract class Server : Object {

		/**
		 * Application handling incoming request.
		 */
		protected VSGI.Application application;

		/**
		 * Creates a new Server that serve a given application.
		 *
		 * @param app application served by this server.
		 */
		public Server (VSGI.Application app) {
			this.application = app;
		}

		/**
		 * Start listening on incoming requests.
		 */
		public abstract void listen ();
	}
}
