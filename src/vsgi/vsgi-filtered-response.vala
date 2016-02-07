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
	 * Base to build {@link VSGI.Response} filters.
	 *
	 * @since 0.2
	 */
	public abstract class FilteredResponse : Response {

		/**
		 * @since 0.2
		 */
		public Response base_response { construct; get; }

		public override uint status  {
			get { return base_response.status; }
			set { base_response.status = value; }
		}

		public override string? reason_phrase {
			owned get { return base_response.reason_phrase; }
			set { base_response.reason_phrase = value; }
		}

		public override MessageHeaders headers {
			get { return base_response.headers; }
		}

		public override OutputStream body {
			get { return base_response.body; }
		}
	}
}
