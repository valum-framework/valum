
using GLib;
using VSGI;

namespace Valum {

	/**
	 * Route supporting the wildcard '*' path.
	 *
	 * @since 0.3
	 */
	public class WildcardRoute : Route {

		public WildcardRoute (Method method, owned HandlerCallback handler) {
			Object (method: method);
		}

		public override bool match (Request req, Context ctx) {
			return "*" == req.uri.get_path ();
		}
	}
}
