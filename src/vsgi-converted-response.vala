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
	 * Apply a {@link GLib.Converter} on the base response body.
	 *
	 * @since 0.2
	 */
	public class ConvertedResponse : FilteredResponse {

		private ConverterOutputStream? converted_body = null;

		/**
		 * @since 0.2
		 */
		public Converter converter { construct; get; }

		public override OutputStream body {
			get {
				if (converted_body == null)
					converted_body = new ConverterOutputStream (base_response.body, converter);
				return converted_body;
			}
		}

		/**
		 * @since 0.2
		 */
		public ConvertedResponse (Response base_response, Converter converter) {
			Object (request: base_response.request, base_response: base_response, converter: converter);
		}
	}
}
