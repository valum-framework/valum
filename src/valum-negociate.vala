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
	 * Negociate a HTTP header against a given expectation.
	 *
	 * The header is extracted as a quality list and a lookup is performed to
	 * see if the expected value is accepted by the user agent.
	 *
	 * @since 0.3
	 *
	 * @param header_name header to negociate
	 * @param expectation expected value in the quality list
	 */
	public HandlerCallback negociate (string header_name, string expectation, owned HandlerCallback forward) {
		return (req, res, next, stack) => {
			var header = req.headers.get_list (header_name);
			if (header != null && header_parse_quality_list (header, null).find_custom (expectation, strcmp) != null) {
				forward (req, res, next, stack);
			} else {
				next (req, res);
			}
		};
	}

	/**
	 * @since 0.3
	 */
	public HandlerCallback accept (string content_type, owned HandlerCallback forward) {
		return negociate ("Accept", content_type, (owned) forward);
	}

	/**
	 * @since 0.3
	 */
	public HandlerCallback accept_charset (string charset, owned HandlerCallback forward) {
		return negociate ("Accept-Charset", charset, (owned) forward);
	}

	/**
	 * @since 0.3
	 */
	public HandlerCallback accept_encoding (string encoding, owned HandlerCallback forward) {
		return negociate ("Accept-Encoding", encoding, (owned) forward);
	}

	/**
	 * @since 0.3
	 */
	public HandlerCallback accept_language (string language, owned HandlerCallback forward) {
		return negociate ("Accept-Language", language, (owned) forward);
	}

	/**
	 * @since 0.3
	 */
	public HandlerCallback accept_ranges (string ranges, owned HandlerCallback forward) {
		return negociate ("Accept-Ranges", ranges, (owned) forward);
	}
}
