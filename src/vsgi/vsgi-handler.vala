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

[Version (since = "0.3")]
public abstract class VSGI.Handler : Object {

	/**
	 * Process a pair of {@link VSGI.Request} and {@link VSGI.Response}.
	 *
	 * It is passed to a {@link VSGI.Server} in order to receive request to
	 * process.
	 *
	 * @throws Error unrecoverable error condition can be raised and will be
	 *               handled by the implementation
	 *
	 * @param req a resource being requested
	 * @param res the response to that request
	 *
	 * @return 'true' if the request has been or will eventually be handled,
	 *         otherwise 'false'
	 */
	[Version (since = "0.3")]
	public virtual bool handle (Request req, Response res) throws Error {
		error ("Either 'handle' or 'handle_async' must be implemented.");
	}

	public virtual async bool handle_async (Request req, Response res) throws Error
	{
		var result = false;
		Error? err = null;
		IOSchedulerJob.push ((job) => {
			var _req = req;
			var _res = res;
			try {
				result = handle (_req, _res);
			} catch (Error _err) {
				err = _err;
			}
			return job.send_to_mainloop (handle_async.callback);
		}, GLib.Priority.DEFAULT);
		yield;
		if (err == null) {
			return result;
		} else {
			throw err;
		}
	}
}
