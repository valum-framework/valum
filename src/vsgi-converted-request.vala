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
	 * Apply a {@link GLib.Converter} on the base request body.
	 *
	 * @since 0.2
	 */
	public class ConvertedRequest : FilteredRequest {

		private ConverterInputStream? converted_body = null;

		/**
		 * @since 0.2
		 */
		public Converter converter { construct; get; }

		public override InputStream body {
			get {
				if (converted_body == null)
					converted_body = new ConverterInputStream (base_request.body, converter);
				return converted_body;
			}
		}

		/**
		 * @since 0.2
		 */
		public ConvertedRequest (Request base_request, Converter converter) {
			Object (base_request: base_request, converter: converter);
		}
	}
}
