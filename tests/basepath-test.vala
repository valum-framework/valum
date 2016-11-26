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
using VSGI;

public int main (string[] args) {
	Test.init (ref args);

	Test.add_func ("/basepath", () => {
		var req = new Request.with_uri (new Soup.URI ("http://localhost/base/"));
		var res = new Response (req);
		var ctx = new Context ();

		try {
			basepath ("/base", (req) => {
				assert ("/" == req.uri.get_path ());
				return true;
			}) (req, res, () => {
				assert_not_reached ();
			}, ctx);
		} catch (Error err) {
			assert_not_reached ();
		}
	});

	Test.add_func ("/basepath/next", () => {
		var req = new Request.with_uri (new Soup.URI ("http://localhost/other_base/"));
		var res = new Response (req);
		var ctx = new Context ();

		try {
			var reached = basepath ("/base", (req) => {
				assert_not_reached ();
			}) (req, res, () => {
				return true;
			}, ctx);
			assert (reached);
		} catch (Error err) {
			assert_not_reached ();
		}
	});

	Test.add_func ("/basepath/empty_path", () => {
		var req = new Request.with_uri (new Soup.URI ("http://localhost/base"));
		var res = new Response (req);
		var ctx = new Context ();

		try {
			basepath ("/base", (req) => {
				assert ("/" == req.uri.get_path ());
				return true;
			}) (req, res, () => {
				assert_not_reached ();
			}, ctx);
		} catch (Error err) {
			assert_not_reached ();
		}
	});

	Test.add_func ("/basepath/restore_path_on_next", () => {
		var req = new Request.with_uri (new Soup.URI ("http://localhost/base"));
		var res = new Response (req);
		var ctx = new Context ();

		try {
			basepath ("/base", (req, res, next) => {
				assert ("/" == req.uri.get_path ());
				return next ();
			}) (req, res, () => {
				assert ("/base" == req.uri.get_path ());
				return true;
			}, ctx);
		} catch (Error err) {
			assert_not_reached ();
		}
	});

	Test.add_func ("/basepath/restore_path_on_error", () => {
		var req = new Request.with_uri (new Soup.URI ("http://localhost/base"));
		var res = new Response (req);
		var ctx = new Context ();

		try {
			basepath ("/base", (req, res, next) => {
				assert ("/" == req.uri.get_path ());
				throw new ClientError.NOT_FOUND ("");
			}) (req, res, () => {
				assert_not_reached ();
			}, ctx);
		} catch (ClientError.NOT_FOUND r) {
			assert ("/base" == req.uri.get_path ());
		} catch (Error err) {
			assert_not_reached ();
		}
	});

	Test.add_func ("/basepath/rewrite_location_header", () => {
		var req = new Request.with_uri (new Soup.URI ("http://localhost/base"));
		var res = new Response (req);
		var ctx = new Context ();

		try {
			basepath ("/base", (req, res, next) => {
				assert ("/" == req.uri.get_path ());
				res.headers.replace ("Location", "/5");
				return next ();
			}) (req, res, () => {
				assert ("/base/5" == res.headers.get_one ("Location"));
				return true;
			}, ctx);
		} catch (Error err) {
			assert_not_reached ();
		}
	});

	Test.add_func ("/basepath/rewrite_location_header_on_error", () => {
		var req = new Request.with_uri (new Soup.URI ("http://localhost/base"));
		var res = new Response (req);
		var ctx = new Context ();

		try {
			basepath ("/base", (req, res, next) => {
				assert ("/" == req.uri.get_path ());
				res.headers.replace ("Location", "/5");
				throw new ClientError.NOT_FOUND ("");
			}) (req, res, () => {
				assert_not_reached ();
			}, ctx);

		} catch (ClientError err) {
			assert ("/base/5" == res.headers.get_one ("Location"));
		} catch (Error err) {
			assert_not_reached ();
		}
	});

	Test.add_func ("/basepath/keep_location_header_intact_on_head_written", () => {
		var req = new Request.with_uri (new Soup.URI ("http://localhost/base"));
		var res = new Response (req);
		var ctx = new Context ();

		try {
			basepath ("/base", (req, res, next) => {
				res.headers.replace ("Location", "/5");
				size_t bytes_written;
				res.write_head (out bytes_written);
				return next ();
			}) (req, res, () => {
				assert ("/5" == res.headers.get_one ("Location"));
				return true;
			}, ctx);
		} catch (Error err) {
			assert_not_reached ();
		}
	});

	Test.add_func ("/basepath/success_created/prefix_message", () => {
		var req = new Request.with_uri (new Soup.URI ("http://localhost/base"));
		var res = new Response (req);
		var ctx = new Context ();

		try {
			basepath ("/base", (req, res, next) => {
				assert ("/" == req.uri.get_path ());
				throw new Success.CREATED ("/5");
			}) (req, res, () => {
				assert_not_reached ();
			}, ctx);
		} catch (Success.CREATED s) {
			assert ("/base/5" == s.message);
			assert ("/base" == req.uri.get_path ());
		} catch (Error err) {
			assert_not_reached ();
		}
	});

	Test.add_func ("/basepath/success_created/omit_non_relative_message", () => {
		var req = new Request.with_uri (new Soup.URI ("http://localhost/base"));
		var res = new Response (req);
		var ctx = new Context ();

		try {
			basepath ("/base", (req, res, next) => {
				assert ("/" == req.uri.get_path ());
				throw new Success.CREATED ("http://localhost/5");
			}) (req, res, () => {
				assert_not_reached ();
			}, ctx);
		} catch (Success.CREATED s) {
			assert ("http://localhost/5" == s.message);
			assert ("/base" == req.uri.get_path ());
		} catch (Error err) {
			assert_not_reached ();
		}
	});

	Test.add_func ("/basepath/redirection", () => {
		var req = new Request.with_uri (new Soup.URI ("http://localhost/base"));
		var res = new Response (req);
		var ctx = new Context ();

		try {
			basepath ("/base", (req, res, next) => {
				assert ("/" == req.uri.get_path ());
				throw new Redirection.FOUND ("/5");
			}) (req, res, () => {
				assert_not_reached ();
			}, ctx);
		} catch (Redirection.FOUND r) {
			assert ("/base/5" == r.message);
			assert ("/base" == req.uri.get_path ());
		} catch (Error err) {
			assert_not_reached ();
		}
	});

	return Test.run ();
}
