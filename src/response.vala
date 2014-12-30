using Gee;
using Soup;

namespace Valum {
	public abstract class Response : Object {

		public abstract string mime { get; set; }

		public abstract uint status { get; set; }

		public MultiMap<string, string> headers { construct; get; }

		public DataOutputStream body { construct; get; }
	}
}
