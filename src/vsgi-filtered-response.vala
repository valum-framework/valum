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

		public override MessageHeaders headers {
			get { return base_response.headers; }
		}

		public override OutputStream body {
			get { return base_response.body; }
		}
	}
}
