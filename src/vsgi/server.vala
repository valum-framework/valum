namespace VSGI {

	/**
	 * Server that feeds a {@link VSGI.Application} with incoming requests.
	 *
	 * Once you have initialized a Server instance, start it by calling
	 * {@link Server.run} with the command-line arguments or a set of predefined
	 * arguments.
     *
	 * Implementation must take the served application as a single argument.
	 *
	 * Handling of CLI arguments should occur in {@link GLib.Application.handle_local_options}
	 * and the server should start processing in {@link GLib.Application.activate}.
	 *
	 * {@link GLib.Application.hold} and {@link GLib.Application.release} are
	 * called whenever a request is processing starts and completes so that the
	 * process timeout properly if it's out of work.
	 *
	 * @since 0.1
	 */
	public class Server : GLib.Application {

		/**
		 * Application being served.
		 *
		 * @since 0.1
		 */
		public VSGI.Application application { construct; get; }
	}
}
