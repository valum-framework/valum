using Soup;

namespace Valum {

	/**
	 * Redirection
	 *
	 * The error message will be used in the Location header.
	 *
	 * These are designed to be thrown in {@link Route.RouteCallback}.
	 *
	 * @see Soup.Status
	 */
	public errordomain Redirection {
		MULTIPLE_CHOICES               = Status.MULTIPLE_CHOICES,
		MOVED_PERMANENTLY              = Status.MOVED_PERMANENTLY,
		FOUND                          = Status.FOUND,
		MOVED_TEMPORARILY              = Status.MOVED_TEMPORARILY,
		SEE_OTHER                      = Status.SEE_OTHER,
		NOT_MODIFIED                   = Status.NOT_MODIFIED,
		USE_PROXY                      = Status.USE_PROXY,
		NOT_APPEARING_IN_THIS_PROTOCOL = Status.NOT_APPEARING_IN_THIS_PROTOCOL,
		TEMPORARY_REDIRECT             = Status.TEMPORARY_REDIRECT
	}

	/**
	 * Client errors
	 *
	 * These can be thrown in {@link Route.RouteCallback}.
	 *
	 * @see Soup.Status
	 */
	public errordomain ClientError {
		BAD_REQUEST                     = Status.BAD_REQUEST,
		UNAUTHORIZED                    = Status.UNAUTHORIZED,
		PAYMENT_REQUIRED                = Status.PAYMENT_REQUIRED,
		FORBIDDEN                       = Status.FORBIDDEN,
		NOT_FOUND                       = Status.NOT_FOUND,
		/**
		 * The error message is used for the 'Allow' header value.
		 */
		METHOD_NOT_ALLOWED              = Status.METHOD_NOT_ALLOWED,
		NOT_ACCEPTABLE                  = Status.NOT_ACCEPTABLE,
		PROXY_AUTHENTICATION_REQUIRED   = Status.PROXY_AUTHENTICATION_REQUIRED,
		PROXY_UNAUTHORIZED              = Status.PROXY_UNAUTHORIZED,
		REQUEST_TIMEOUT                 = Status.REQUEST_TIMEOUT,
		CONFLICT                        = Status.CONFLICT,
		GONE                            = Status.GONE,
		LENGTH_REQUIRED                 = Status.LENGTH_REQUIRED,
		PRECONDITION_FAILED             = Status.PRECONDITION_FAILED,
		REQUEST_ENTITY_TOO_LARGE        = Status.REQUEST_ENTITY_TOO_LARGE,
		REQUEST_URI_TOO_LONG            = Status.REQUEST_URI_TOO_LONG,
		UNSUPPORTED_MEDIA_TYPE          = Status.UNSUPPORTED_MEDIA_TYPE,
		REQUESTED_RANGE_NOT_SATISFIABLE = Status.REQUESTED_RANGE_NOT_SATISFIABLE,
		INVALID_RANGE                   = Status.INVALID_RANGE,
		EXPECTATION_FAILED              = Status.EXPECTATION_FAILED,
		UNPROCESSABLE_ENTITY            = Status.UNPROCESSABLE_ENTITY,
		LOCKED                          = Status.LOCKED,
		FAILED_DEPENDENCY               = Status.FAILED_DEPENDENCY
	}

	/**
	 * Server errors.
	 *
	 * These can be thrown in {@link Route.RouteCallback}.
	 *
	 * @see Soup.Status
	 */
	public errordomain ServerError {
		INTERNAL_SERVER_ERROR      = Status.INTERNAL_SERVER_ERROR,
		NOT_IMPLEMENTED            = Status.NOT_IMPLEMENTED,
		BAD_GATEWAY                = Status.BAD_GATEWAY,
		SERVICE_UNAVAILABLE        = Status.SERVICE_UNAVAILABLE,
		GATEWAY_TIMEOUT            = Status.GATEWAY_TIMEOUT,
		HTTP_VERSION_NOT_SUPPORTED = Status.HTTP_VERSION_NOT_SUPPORTED,
		INSUFFICIENT_STORAGE       = Status.INSUFFICIENT_STORAGE,
		NOT_EXTENDED               = Status.NOT_EXTENDED
	}
}
