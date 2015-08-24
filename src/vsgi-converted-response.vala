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
			Object (base_response: base_response, converter: converter);
		}
	}
}
