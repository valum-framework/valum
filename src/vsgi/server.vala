namespace VSGI {

	/**
	 * Server that feeds a {@link VSGI.ApplicationCallback} with incoming
	 * requests.
	 *
	 * Once you have initialized a Server instance, start it by calling
	 * {@link GLib.Application.run} with the command-line arguments or a set of
	 * predefined arguments.
	 *
	 * The server can be implemented by overriding the {@link GLib.Application.command_line}
	 * signal.
	 *
	 * If the implementaiton is actively listening for incoming requests,
	 * {@link GLib.Application.hold} and {@link GLib.Application.release} to
	 * maintain a hold count per request and automatically exit after a certain
	 * idle timeout.
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
		 * and set the {@link ApplicationFlags.HANDLES_COMMAND_LINE} flag.
		 *
		 * @param application served application
		 *
		 * @since 0.2
		 */
		public Server (ApplicationCallback application) {
			Object (flags: ApplicationFlags.HANDLES_COMMAND_LINE);
			this.handle = application;
		}
	}
}
