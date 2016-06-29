using VSGI;

namespace Valum {

	/**
	 * Define a kind of {@link Valum.HandlerCallback} which may only raise
	 * status codes so that other errors have to be explicitly handled.
	 *
	 * @since 0.3
	 */
	public delegate bool SafeHandlerCallback (Request req, Response res, NextCallback next, Context ctx) throws Informational,
	                                                                                                            Success,
		                                                                                                        Redirection,
		                                                                                                        ClientError,
		                                                                                                        ServerError;

	/**
	 * Perform some operations safely.
	 *
	 * Typically, errors are thrown out of callbacks and handled altogether.
	 * However, some critical sections might not want to have errors leaking, so
	 * this middleware ensure that by providing a context where no errors, but
	 * status can be raised.
	 *
	 * @since 0.3
	 */
	public HandlerCallback safely (owned SafeHandlerCallback forward) {
		return (req, res, next, ctx) => {
			return forward (req, res, next, ctx);
		};
	}
}

