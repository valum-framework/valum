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

using GLib;

namespace Valum {

	/**
	 * Extract subdomains from a domain name excluding the top and second level
	 * domain.
	 *
	 * @since 0.3
	 *
	 * @param domain domain from which subdomains will be extracted
	 * @param skip   number of labels to skip, which defaults to 2 (eg. 'example'
	 *               and 'com')
	 * @return a list of subdomains in their left-to-right order of appearance
	 *         in the domain excluding the two top-most levels
	 */
	public string[] extract_subdomains (string domain, uint skip = 2) {
		var labels = domain.split (".");
		if (labels.length <= skip)
			return {};
		return labels[0:labels.length - skip];
	}

	/**
	 * Flags for {@link Valum.subdomain}
	 */
	[Flags]
	public enum SubdomainFlags {
		NONE,
		/**
		 * Strictly match the subdomains to have the exactly same amount of
		 * labels.
		 *
		 * @since 0.3
		 */
		STRICT
	}


	/**
	 * Produce a matching middleware that accepts request which subdomain is
	 * consistent with the expectation.
	 *
	 * If the expected subdomain is 'api', then 'api.example.com' and
	 * '*.api.example.com' will be accepted.
	 *
	 * The joker '*' can be used to fuzzy-match a label.
	 *
	 * @since 0.3
	 *
	 * @param expected_subdomain expected subdomain pattern
	 * @param forward            invoked if the subdomain matches
	 * @param flags              see {@link Valum.SubdomainFlags}
	 * @param skip               see {@link Valum.extract_subdomains}
	 */
	public HandlerCallback subdomain (string expected_subdomain,
	                                  owned HandlerCallback forward,
	                                  SubdomainFlags flags = SubdomainFlags.NONE,
	                                  uint skip            = 2) {
		return (req, res, next, stack) => {
			var expected_labels = expected_subdomain.split (".");
			var labels          = extract_subdomains (req.uri.host, skip);
			if (expected_labels.length > labels.length) {
				next (req, res); return;
			}
			if (SubdomainFlags.STRICT in flags && expected_labels.length != labels.length) {
				next (req, res); return;
			}
			for (var i = 1; i <= expected_labels.length; i++) {
				if (expected_labels[expected_labels.length - i] != "*" &&
					expected_labels[expected_labels.length - i] != labels[labels.length - i]) {
					next (req, res); return;
				}
			}
			forward (req, res, next, stack);
		};
	}
}
