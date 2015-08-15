namespace VSGI {

	/**
	 * Server that feeds a {@link VSGI.ApplicationCallback} with incoming
	 * requests.
	 *
	 * Once you have initialized a Server instance, start it by calling
	 * {@link GLib.Application.run} with the command-line arguments or a set of
	 * predefined arguments.
	 *
	 * The server should be implemented by overriding the
	 * {@link GLib.Application.command_line} signal.
	 *
	 * @since 0.1
	 */
	public class Server : GLib.Application {

		/**
		 * Handle a pair of {@link VSGI.Request} and {@link VSGI.Response}.
		 *
		 * @since 0.2
		 */
		protected ApplicationCallback handle;

		/**
		 * Enforces implementation to take the application as a sole argument
		 * and set the {@link GLib.ApplicationFlags.HANDLES_COMMAND_LINE},
		 * {@link GLib.ApplicationFlags.SEND_ENVIRONMENT} and
		 * {@link GLib.ApplicationFlags.NON_UNIQUE} flags.
		 *
		 * @param application served application
		 *
		 * @since 0.2
		 */
		public Server (string application_id, owned ApplicationCallback application) {
			Object (application_id: application_id, flags: ApplicationFlags.HANDLES_COMMAND_LINE | ApplicationFlags.SEND_ENVIRONMENT | ApplicationFlags.NON_UNIQUE);
			this.handle = (owned) application;
		}
	}
}
