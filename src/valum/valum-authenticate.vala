
using GLib;
using VSGI;

namespace Valum {

	/**
	 * Hash the provided plain password.
	 *
	 * If basic authentication is used, this will simply return the input.
	 * However, if digest is used, it will hash the password accordingly. This
	 * is why the callback should always be applied on plain passwords.
	 *
	 * @since 0.3
	 */
	public delegate string HashPasswordCallback (string password);

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
	public delegate bool AuthCallback (string username, string password, owned HashPasswordCallback hash);

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
			var authorization = req.headers.get_one ("Authorization");

			if (authorization != null) {
				string username, password;
				if (auth.parse_authorization_header (authorization, out username, out password)) {
					if (callback (username, password, auth.hash_password)) {
						return forward (req, res, next, ctx, username);
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
