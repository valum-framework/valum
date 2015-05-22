namespace VSGI {

	/**
	 * Server that feeds a {@link VSGI.Application} with incoming requests.
	 *
	 * Once you have initialized a Server instance, start it by calling
	 * {@link GLib.Application.run} with the command-line arguments, a set of
	 * predefined arguments or nothing at all.
     *
	 * Implementation must take the served application as a single argument for
	 * consistency.
	 *
	 * {@link GLib.Application.hold} and {@link GLib.Application.release} are
	 * called whenever a request is processing starts and completes so that the
	 * process timeout properly if a default timeout is set. A timeout of '0'
	 * means to keep the server alive, which can be implemented by never
	 * releasing the initial hold.
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
