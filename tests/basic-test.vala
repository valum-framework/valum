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
using Valum;
using VSGI;

public int main (string[] args) {
	Test.init (ref args);

	Test.add_func ("/basic/reason_phrase_for_unknown_status", () => {
		var ctx = new Context ();

		Request req;
		Response res;

		req = new Request (null, "GET", new Soup.URI ("http://localhost/"));
		res = new Response (req);
		try {
			assert (basic () (req, res, () => {
				throw new Success.ALREADY_REPORTED ("");
			}, ctx));
		} catch (Error err) {
			assert_not_reached ();
		}
		assert ("Already Reported" == res.reason_phrase);

		req = new Request (null, "GET", new Soup.URI ("http://localhost/"));
		res = new Response (req);
		try {
			assert (basic () (req, res, () => {
				res.reason_phrase = "Not Already Reported";
				throw new Success.ALREADY_REPORTED ("");
			}, ctx));
		} catch (Error err) {
			assert_not_reached ();
		}
		assert ("Not Already Reported" == res.reason_phrase);
	});

	return Test.run ();
}
