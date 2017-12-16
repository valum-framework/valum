using VSGI;

namespace Valum {

	/**
	 * Define a kind of {@link Valum.HandlerCallback} which may only raise
	 * status codes so that other errors have to be explicitly handled.
	 */
	[Version (since = "0.3")]
	public delegate bool SafeHandlerCallback (Request req, Response res, SafeNextCallback next, Context ctx) throws Informational,
	                                                                                                                Success,
	                                                                                                                Redirection,
	                                                                                                                ClientError,
	                                                                                                                ServerError;

	[Version (since = "0.3")]
	public delegate bool SafeNextCallback () throws Informational,
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
	 * The 'next' continuation is wrapped in such way that if any non-status
	 * error is raised, it will be thrown upstream but not leaked from invoking
	 * it. This is useful because one only want to deal with errors in the direct
	 * scope.
	 */
	[Version (since = "0.3")]
	public HandlerCallback safely (owned SafeHandlerCallback forward) {
		return (req, res, next, ctx) => {
			Error? err = null;
			var ret = forward (req, res, () => {
				try {
					return next ();
				} catch (Informational i) {
					throw i;
				} catch (Success s) {
					throw s;
				} catch (Redirection r) {
					throw r;
				} catch (ClientError c) {
					throw c;
				} catch (ServerError s) {
					throw s;
				} catch (Error _err) {
					err = (owned) _err;
					return false;
				}
			}, ctx);
			if (err != null)
				throw err;
			return ret;
		};
	}
}

