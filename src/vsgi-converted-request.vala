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
