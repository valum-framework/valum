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

/**
 * Subdomain utilities.
 *
 * @since 0.3
 */
namespace Valum.Subdomain {

	/**
	 * Extract subdomains from a domain name excluding the top and second level
	 * domain.
	 *
	 * @since 0.3
	 *
	 * @param domain
	 * @param skip   number of labels to skip, which defaults to 2 (eg. 'example'
	 *               and 'com')
	 * @return a list of subdomains in their left-to-right order of appearance
	 *         in the domain excluding the two top-most levels
	 */
	public string[] extract (string domain, uint skip = 2) {
		var labels = domain.split (".");
		if (labels.length <= skip)
			return {};
		return labels[0:labels.length - skip];
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
	 * @param strict             strictly match the subdomain by refusing sub-subdomains
	 * @param skip               see {@link Valum.Subdomain.extract}
	 */
	public MatcherCallback subdomain (string expected_subdomain, bool strict = false, uint skip = 2) {
		return (req) => {
			var expected_labels = expected_subdomain.split (".");
			var labels          = extract (req.uri.host, skip);
			if (expected_labels.length > labels.length)
				return false;
			if (strict && expected_labels.length != labels.length)
				return false;
			for (var i = 1; i <= expected_labels.length; i++)
				if (expected_labels[expected_labels.length - i] != "*" &&
					expected_labels[expected_labels.length - i] != labels[labels.length - i])
					return false;
			return true;
		};
	}
}
