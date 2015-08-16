using GLib;
using Soup;

namespace VSGI {

	/**
	 * Base to build {@link VSGI.Request} filters.
	 *
	 * @since 0.2
	 */
	public abstract class RequestFilter : Request {

		/**
		 * @since 0.2
		 */
		public Request base_request { construct; get; }

		public override string method {
			owned get { return base_request.method; }
		}

		public override URI uri {
			get { return base_request.uri; }
		}

		public override HashTable<string, string>? query {
			get { return base_request.query; }
		}

		public override HTTPVersion http_version {
			get { return base_request.http_version; }
		}

		public override MessageHeaders headers {
			get { return base_request.headers; }
		}

		public override InputStream body {
			get { return base_request.body; }
		}
	}
}
