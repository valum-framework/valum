/*
 * This file is part of Valum.
 *
 * Valum is free software: you can redistribute it and/or modify it under the
 * terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) any
 * later version.
 *
 * Valum is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with Valum.  If not, see <http://www.gnu.org/licenses/>.
 */

using GLib;

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
