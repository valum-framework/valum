/*
 * This file is part of Valum.
 *
 * Valum is free software: you can redistribute it and/or modify it under the
 * terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) any
 * later version.
 *
 * Valum is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with Valum.  If not, see <http://www.gnu.org/licenses/>.
 */

using Soup;

namespace Valum {

	/**
	 * Informational status corresponding to the 1xx HTTP status codes.
	 *
	 * @see   Soup.Status
	 * @since 0.1
	 */
	public errordomain Informational {
		CONTINUE            = Status.CONTINUE,
		/**
		 * The error message will be used for the 'Upgrade' header.
		 */
		SWITCHING_PROTOCOLS = Status.SWITCHING_PROTOCOLS,
		PROCESSING          = Status.PROCESSING
	}

	/**
	 * Success corresponding to the 2xx HTTP status codes.
	 *
	 * @see   Soup.Status
	 * @since 0.1
	 */
	public errordomain Success {
		OK                = Status.OK,
		/**
		 * The error message will be used for the 'Location' header which
		 * should point to the newly created resource.
		 */
		CREATED           = Status.CREATED,
		ACCEPTED          = Status.ACCEPTED,
		NON_AUTHORITATIVE = Status.NON_AUTHORITATIVE,
		NO_CONTENT        = Status.NO_CONTENT,
		RESET_CONTENT     = Status.RESET_CONTENT,
		/**
		 * The error message will be used for the 'Range' header.
		 */
		PARTIAL_CONTENT   = Status.PARTIAL_CONTENT,
		MULTI_STATUS      = Status.MULTI_STATUS,
		ALREADY_REPORTED  = 208,
		IM_USED           = 226
	}

	/**
	 * Redirection corresponding to the 3xx HTTP status codes.
	 *
	 * The error message will be used in the 'Location' header.
	 *
	 * @see   Soup.Status
	 * @since 0.1
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
		TEMPORARY_REDIRECT             = Status.TEMPORARY_REDIRECT,
		PERMANENT_REDIRECT             = 308
	}

	/**
	 * Client errors corresponding to the 4xx HTTP status codes.
	 *
	 * @see   Soup.Status
	 * @since 0.1
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
		IM_A_TEAPOT                     = 418,
		AUTHENTICATION_TIMEOUT          = 419,
		MISDIRECTED_REQUEST             = 421,
		UNPROCESSABLE_ENTITY            = Status.UNPROCESSABLE_ENTITY,
		LOCKED                          = Status.LOCKED,
		FAILED_DEPENDENCY               = Status.FAILED_DEPENDENCY,
		/**
		 * The error message is used for the 'Upgrade' header.
		 */
		UPGRADE_REQUIRED                = 426,
		PRECONDITION_REQUIRED           = 428,
		TOO_MANY_REQUESTS               = 429,
		REQUEST_HEADER_FIELDS_TOO_LARGE = 431
	}

	/**
	 * Server errors corresponding to the 5xx HTTP status codes.
	 *
	 * @see   Soup.Status
	 * @since 0.1
	 */
	public errordomain ServerError {
		INTERNAL_SERVER_ERROR           = Status.INTERNAL_SERVER_ERROR,
		NOT_IMPLEMENTED                 = Status.NOT_IMPLEMENTED,
		BAD_GATEWAY                     = Status.BAD_GATEWAY,
		SERVICE_UNAVAILABLE             = Status.SERVICE_UNAVAILABLE,
		GATEWAY_TIMEOUT                 = Status.GATEWAY_TIMEOUT,
		HTTP_VERSION_NOT_SUPPORTED      = Status.HTTP_VERSION_NOT_SUPPORTED,
		VARIANT_ALSO_NEGOTIATES         = 506,
		INSUFFICIENT_STORAGE            = Status.INSUFFICIENT_STORAGE,
		LOOP_DETECTED                   = 508,
		NOT_EXTENDED                    = Status.NOT_EXTENDED,
		NETWORK_AUTHENTICATION_REQUIRED = 511
	}
}
