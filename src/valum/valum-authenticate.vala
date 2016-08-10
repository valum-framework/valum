
using GLib;
using VSGI;

namespace Valum {

	/**
	 * Perform the authentication against the credentials source.
	 *
	 * @since 0.3
	 *
	 * @param username client identification if appliable
	 * @param password secret against which we perform the authentication
	 *
	 * @return 'true' if the 'secret_id' authenticates the 'client_id', otherwise
	 *         'false' even if any of the provided input is malformed
	 */
	public delegate bool AuthCallback (Authorization auth);

	/**
	 * Challenge incoming requests against the provided authentication
	 * definition.
	 *
	 * On success, the request is forwarded with the authenticated username.
	 *
	 * @since 0.3
	 */
	public HandlerCallback authenticate (Authentication                auth,
	                                     owned AuthCallback            callback,
	                                     owned ForwardCallback<string> forward = Valum.forward) {
		return (req, res, next, ctx) => {
			var authorization_header = req.headers.get_one ("Authorization");

			if (authorization_header != null) {
				Authorization authorization;
				if (auth.parse_authorization_header (authorization_header, out authorization)) {
					if (callback (authorization)) {
						return forward (req, res, next, ctx, authorization.username);
					} else {
						// authentication failed
					}
				} else {
					// malformed authentication
				}
			}

			throw new ClientError.UNAUTHORIZED (auth.to_authenticate_header ());
		};
	}
}
