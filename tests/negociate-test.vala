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

using Valum;
using VSGI.Mock;

/**
 * @since 0.3
 */
public void test_negociate () {
	var req   = new Request (new Connection (), "GET", new Soup.URI ("http://localhost/"));
	var res   = new Response (req);

	req.headers.append ("Accept", "text/html; q=0.9, text/xml; q=0");

	try {
		negociate ("Accept", "text/html", () => { return true; }) (req, res, () => {
			assert_not_reached ();
		}, new Context ());

		negociate ("Accept", "text/xml", () => {
			assert_not_reached ();
		}) (req, res, () => { return true; }, new Context ());

		negociate ("Accept-Encoding", "utf-8", () => {
			assert_not_reached ();
		}) (req, res, () => { return true; }, new Context ());
	} catch (Error err) {
		assert_not_reached ();
	}
}


