namespace Valum {

	/**
	 * Produce a handler sequence of 'a' and 'b'.
	 *
	 * @since 0.3
	 */
	public HandlerCallback sequence (owned HandlerCallback a, owned HandlerCallback b) {
		return (req, res, next, ctx) => {
			return a (req, res, () => {
				return b (req, res, next, ctx);
			}, ctx);
		};
	}
}
