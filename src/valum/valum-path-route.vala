using VSGI;

/**
 * Route based on exact path matching.
 *
 * @since 0.3
 */
public class Valum.PathRoute : Valum.Route {

	/**
	 * The path matched by this route.
	 *
	 * @since 0.3
	 */
	public string path { construct; get; }

	/**
	 * @since 0.3
	 */
	public PathRoute (Method method, string path, owned HandlerCallback handler) {
		Object (method: method, path: path);
		_fire = (owned) handler;
	}

	public override bool match (Request req, Context ctx) {
		return req.uri.get_path () == path;
	}

	private HandlerCallback _fire;

	public override bool fire (Request req, Response res, NextCallback next, Context ctx) throws Error {
		return _fire (req, res, next, ctx);
	}

	public override string to_url_from_hash (HashTable<string, string>? @params = null) {
		return path;
	}
}
