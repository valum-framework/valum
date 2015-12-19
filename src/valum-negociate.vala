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
	public MatcherCallback negociate (string header_name, string expectation) {
		return (req) => {
			var header = req.headers.get_list (header_name);
			return header != null && header_parse_quality_list (header, null).find_custom (expectation, strcmp) != null;
		};
	}

	/**
	 * @since 0.3
	 */
	public MatcherCallback accept (string content_type) {
		return negociate ("Accept", content_type);
	}

	/**
	 * @since 0.3
	 */
	public MatcherCallback accept_charset (string charset) {
		return negociate ("Accept-Charset", charset);
	}

	/**
	 * @since 0.3
	 */
	public MatcherCallback accept_encoding (string encoding) {
		return negociate ("Accept-Encoding", encoding);
	}

	/**
	 * @since 0.3
	 */
	public MatcherCallback accept_language (string language) {
		return negociate ("Accept-Language", language);
	}

	/**
	 * @since 0.3
	 */
	public MatcherCallback accept_ranges (string ranges) {
		return negociate ("Accept-Ranges", ranges);
	}
}
