
namespace Valum.AccessControl {
	public HandlerCallback allow (string header, string[] values) {
		return (req, res) => {
			res.headers.append ("Access-Control-%s".printf (header), string.joinv (", ", values));
			return next ();
		};
	}

	/**
	 * @since 0.3
	 */
	public HandlerCallback allow_origins ()

	/**
	 * @since 0.3
	 */
	public HandlerCallback expose_headers ()

	/**
	 * @since 0.3
	 */
	public HandlerCallback max_age ()

	/**
	 * @since 0.3
	 */
	public HandlerCallback allow_credentials ()

	/**
	 * @since 0.3
	 */
	public HandlerCallback allow_methods (string[] allowed_methods) {
		return (req, res, next) => {
			res.headers.append ("Allow-Methods")
			return next ();
		};
	}


	/**
	 * @since 0.3
	 */
	public HandlerCallback allow_headers (string allowed_headers) {
		return (req, res) => {
			res.headers.append ("Allow-Headers", allowed_headers);
		};
	}
}

