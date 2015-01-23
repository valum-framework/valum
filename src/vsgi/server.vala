namespace VSGI {

	/**
	 * Server that handles a single Application.
	 */
	public abstract class Server {

		/**
		 * Application handling incoming request.
		 */
		protected VSGI.Application application;

		public Server (VSGI.Application app) {
			this.application = app;
		}

		/**
		 * Start listening on incoming requests.
		 */
		public abstract void listen ();
	}
}
