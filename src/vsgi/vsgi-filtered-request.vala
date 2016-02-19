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
using Soup;

namespace VSGI {

	/**
	 * Base to build {@link VSGI.Request} filters.
	 *
	 * @since 0.2
	 */
	public abstract class FilteredRequest : Request {

		/**
		 * @since 0.2
		 */
		public Request base_request { construct; get; }

		public override HTTPVersion http_version {
			get { return base_request.http_version; }
		}

		public override string method {
			owned get { return base_request.method; }
		}

		public override URI uri {
			get { return base_request.uri; }
		}

		public override HashTable<string, string>? query {
			get { return base_request.query; }
		}

		public override MessageHeaders headers {
			get { return base_request.headers; }
		}

		public override InputStream body {
			get { return base_request.body; }
		}

		public override uint8[] flatten (Cancellable? cancellable = null) throws IOError {
			return base_request.flatten (cancellable);
		}

		public override async uint8[] flatten_async (int          priority    = GLib.Priority.DEFAULT,
													 Cancellable? cancellable = null) throws IOError {
			return yield base_request.flatten_async (priority, cancellable);
		}
	}
}
