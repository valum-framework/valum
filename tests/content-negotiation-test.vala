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
using Valum.ContentNegotiation;
using VSGI;

public int main (string[] args) {
	Test.init (ref args);

	/**
	 * @since 0.3
	 */
	Test.add_func ("/content_negotiation/negotiate", () => {
		var req = new Request (null, "GET", new Soup.URI ("http://localhost/"));
		var res = new Response (req);
		var ctx = new Context ();

		req.headers.append ("Accept", "text/html; q=0.9, text/xml; q=0");

		var reached = false;
		try {
			negotiate ("Accept", "text/html", (req, res, next, ctx, content_type) => {
				reached = true;
				assert ("text/html" == content_type);
				assert (null == res.headers.get_one ("Vary"));
				return true;
			}) (req, res, () => {
				assert_not_reached ();
			}, ctx);
		} catch (Error err) {
			assert_not_reached ();
		}
		assert (reached);

		// explicitly refuse the content type with 'q=0'
		reached = false;
		try {
			negotiate ("Accept", "text/xml", () => {
				assert_not_reached ();
			}) (req, res, () => {
				assert_not_reached ();
			}, ctx);
		} catch (ClientError.NOT_ACCEPTABLE err) {
			reached = true;
		} catch (Error err) {
			assert_not_reached ();
		}
		assert (reached);

		reached = false;
		try {
			negotiate ("Accept", "application/octet-stream", () => {
				assert_not_reached ();
			}) (req, res, () => {
				assert_not_reached ();
			}, ctx);
		} catch (ClientError.NOT_ACCEPTABLE err) {
			reached = true;
		} catch (Error err) {
			assert_not_reached ();
		}
		assert (reached);

		// no expectations always refuse
		reached = false;
		try {
			negotiate ("Accept", "", () => {
				assert_not_reached ();
			}) (req, res, () => {
				assert_not_reached ();
			}, ctx);
		} catch (ClientError.NOT_ACCEPTABLE err) {
			reached = true;
		} catch (Error err) {
			assert_not_reached ();
		}
		assert (reached);

		// header is missing, so forward unconditionnaly
		assert (null == req.headers.get_one ("Accept-Encoding"));
		reached = false;
		try {
			negotiate ("Accept-Encoding", "utf-8", () => {
				reached = true;
				return true;
			}) (req, res, () => {
				assert_not_reached ();
			}, ctx);
		} catch (Error err) {
			assert_not_reached ();
		}
		assert (reached);
	});

	/**
	 * @since 0.3
	 */
	Test.add_func ("/content_negotiation/negotiate/multiple", () => {
		var req = new Request (null, "GET", new Soup.URI ("http://localhost/"));
		var res = new Response (req);
		var ctx = new Context ();

		req.headers.append ("Accept", "text/html; q=0.9, text/xml; q=0.2");

		try {
			negotiate ("Accept", "text/xml, text/html", (req, res, next, ctx, content_type) => {
				assert ("text/html" == content_type);
				assert ("Accept" == res.headers.get_one ("Vary"));
				return true;
			}) (req, res, () => {
				assert_not_reached ();
			}, ctx);
		} catch (Error err) {
			assert_not_reached ();
		}
	});

	/**
	 * @since 0.3
	 */
	Test.add_func ("/content_negotiation/negotiate/quality", () => {
		var req = new Request (null, "GET", new Soup.URI ("http://localhost/"));
		var res = new Response (req);
		var ctx = new Context ();

		res.headers.append ("Accept", "application/json, text/xml; q=0.9");

		// 0.9 * 0.3 > 1 * 0.2
		try {
			negotiate ("Accept", "application/json; q=0.2, text/xml; q=0.3", (req, res, next, ctx, choice) => {
				assert ("text/xml" == choice);
				return true;
			}) (req, res, () => {
				assert_not_reached ();
			}, ctx);
		} catch (Error err) {
			assert_not_reached ();
		}

		// 1 * 0.4 > 0.9 * 0.3
		try {
			negotiate ("Accept", "application/json; q=0.4, text/xml; q=0.3", (req, res, next, ctx, choice) => {
				assert ("application/json" == choice);
				return true;
			}) (req, res, () => {
				assert_not_reached ();
			}, ctx);
		} catch (Error err) {
			assert_not_reached ();
		}
	});

	/**
	 * @since 0.3
	 */
	Test.add_func ("/content_negotiation/accept", () => {
		var req = new Request (null, "GET", new Soup.URI ("http://localhost/"));
		var res = new Response (req);
		var ctx = new Context ();

		req.headers.append ("Accept", "text/html");

		try {
			accept ("text/html", (req, res, next, ctx, content_type) => {
				assert ("text/html" == content_type);
				return true;
			}) (req, res, () => {
				assert_not_reached ();
			}, ctx);
		} catch (Error err) {
			assert_not_reached ();
		}
		assert ("text/html" == res.headers.get_content_type (null));

		var reached = false;
		try {
			accept ("text/xml", (req, res, next, ctx, content_type) => {
				assert_not_reached ();
			}) (req, res, () => {
				assert_not_reached ();
			}, ctx);
		} catch (ClientError.NOT_ACCEPTABLE err) {
			reached = true;
		} catch (Error err) {
			assert_not_reached ();
		}
		assert (reached);
	});

	/**
	 * @since 0.3
	 */
	Test.add_func ("/content_negotiation/accept/any", () => {
		var req = new Request (null, "GET", new Soup.URI ("http://localhost/"));
		var res = new Response (req);
		var ctx = new Context ();

		req.headers.append ("Accept", "*/*");

		try {
			accept ("text/html", (req, res, next, ctx, content_type) => {
				assert ("text/html" == content_type);
				return true;
			}) (req, res, () => {
				assert_not_reached ();
			}, ctx);
		} catch (Error err) {
			assert_not_reached ();
		}
		assert ("text/html" == res.headers.get_content_type (null));
	});

	/**
	 * @since 0.3
	 */
	Test.add_func ("/content_negotiation/accept/any_subtype", () => {
		var req = new Request (null, "GET", new Soup.URI ("http://localhost/"));
		var res = new Response (req);
		var ctx = new Context ();

		req.headers.append ("Accept", "text/*");
		req.headers.append ("Accept-Encoding", "*");

		try {
		accept ("text/html", (req, res, next, ctx, content_type) => {
			assert ("text/html" == content_type);
			return true;
		}) (req, res, () => {
			assert_not_reached ();
		}, ctx);
		} catch (Error err) {
			assert_not_reached ();
		}
		assert ("text/html" == res.headers.get_content_type (null));

		try {
		accept ("text/xml", (req, res, next, ctx, content_type) => {
			assert ("text/xml" == content_type);
			return true;
		}) (req, res, () => {
			assert_not_reached ();
		}, ctx);
		} catch (Error err) {
			assert_not_reached ();
		}
		assert ("text/xml" == res.headers.get_content_type (null));

		try {
			accept ("application/json", () => {
				 assert_not_reached () ;
			 }) (req, res, () => {
				 assert_not_reached () ;
			 }, ctx);
		} catch (ClientError.NOT_ACCEPTABLE err) {
		} catch (Error err) {
			assert_not_reached ();
		}
	});

	Test.add_func ("/content_negotiation/accept/compound_subtype", () => {
		var req = new Request (null, "GET", new Soup.URI ("http://localhost/"));
		var res = new Response (req);
		var ctx = new Context ();

		req.headers.append ("Accept", "application/json");

		try {
			accept ("application/vnd.api+json", (req, res, next, ctx, content_type) => {
				assert ("application/vnd.api+json" == content_type);
				return true;
			}) (req, res, () => {
				//assert_not_reached ();
				return true;
			}, ctx);
		} catch (Error err) {
			assert_not_reached ();
		}
	});

	Test.add_func ("/content_negotiation/accept_encoding/deflate", () => {
		var req = new Request (null, "GET", new Soup.URI ("http://localhost/"));
		var res = new Response (req);
		var ctx = new Context ();

		req.headers.append ("Accept-Encoding", "deflate");

		try {
			accept_encoding ("deflate", (req, res, next, ctx, encoding) => {
				assert ("deflate" == encoding);
				assert ("deflate" == res.headers.get_one ("Content-Encoding"));
				return true;
			}) (req, res, () => {
				assert_not_reached ();
			}, ctx);
		} catch (Error err) {
			assert_not_reached ();
		}
	});

	Test.add_func ("/content_negotiation/accept_encoding318a59a/identity", () => {
		var req = new Request (null, "GET", new Soup.URI ("http://localhost/"));
		var res = new Response (req);
		var ctx = new Context ();

		req.headers.append ("Accept-Encoding", "identity");

		try {
			accept_encoding ("identity", (req, res, next, ctx, encoding) => {
				assert ("identity" == encoding);
				assert ("identity" == res.headers.get_one ("Content-Encoding"));
				return true;
			}) (req, res, () => {
				assert_not_reached ();
			}, ctx);
		} catch (Error err) {
			assert_not_reached ();
		}
	});
	Test.add_func ("/content_negotiation/accept_encoding/vendor_prefix", () => {
		var req = new Request (null, "GET", new Soup.URI ("http://localhost/"));
		var res = new Response (req);
		var ctx = new Context ();

		req.headers.append ("Accept-Encoding", "x-gzip");

		try {
			accept_encoding ("gzip", (req, res, next, ctx, encoding) => {
				assert ("gzip" == encoding);
				return true;
			}) (req, res, () => {
				assert_not_reached ();
			}, ctx);
		} catch (Error err) {
			assert_not_reached ();
		}
	});

	Test.add_func ("/content_negotiation/identity_always_acceptable", () => {
		var req = new Request (null, "GET", new Soup.URI ("http://localhost/"));
		var res = new Response (req);
		var ctx = new Context ();

		assert (null == req.headers.get_list ("Accept-Encoding"));

		try {
			accept_encoding ("identity", (req, res, next, ctx, encoding) => {
				assert ("identity" == encoding);
				return true;
			}) (req, res, () => {
				assert_not_reached ();
			}, ctx);
		} catch (Error err) {
			assert_not_reached ();
		}
	});

	Test.add_func ("/content_negotiation/identity_explicitly_unacceptable", () => {
		var req = new Request (null, "GET", new Soup.URI ("http://localhost/"));
		var res = new Response (req);
		var ctx = new Context ();

		req.headers.append ("Accept-Encoding", "identity; q=0");

		try {
			accept_encoding ("identity", (req, res, next, ctx, encoding) => {
				assert_not_reached ();
			}) (req, res, () => {
				assert_not_reached ();
			}, ctx);
		} catch (ClientError.NOT_ACCEPTABLE err) {

		} catch (Error err) {
			assert_not_reached ();
		}
	});

	Test.add_func ("/content_negotiation/accept_language", () => {
		var req = new Request (null, "GET", new Soup.URI ("http://localhost/"));
		var res = new Response (req);
		var ctx = new Context ();

		req.headers.append ("Accept-Language", "fr");

		try {
			accept_language ("fr", (req, res, next, ctx, language) => {
				assert ("fr" == language);
				assert ("fr" == res.headers.get_one ("Content-Language"));
				return true;
			}) (req, res, () => {
				assert_not_reached ();
			}, ctx);
		} catch (Error err) {
			assert_not_reached ();
		}
	});

	Test.add_func ("/content_negotiation/accept_language/local_variant", () => {
		var req = new Request (null, "GET", new Soup.URI ("http://localhost/"));
		var res = new Response (req);
		var ctx = new Context ();

		req.headers.append ("Accept-Language", "fr-CA");

		try {
			accept_language ("fr", () => {
				assert ("fr" == res.headers.get_one ("Content-Language"));
				return true;
			}) (req, res, () => {
				assert_not_reached ();
			}, ctx);
		} catch (Error err) {
			assert_not_reached ();
		}
	});

	Test.add_func ("/content_negotiation/accept_language/wildcard", () => {
		var req = new Request (null, "GET", new Soup.URI ("http://localhost/"));
		var res = new Response (req);
		var ctx = new Context ();

		req.headers.append ("Accept-Language", "fr-CA");

		try {
			accept_language ("fr", () => {
				assert ("fr" == res.headers.get_one ("Content-Language"));
				return true;
			}) (req, res, () => {
				assert_not_reached ();
			}, ctx);
		} catch (Error err) {
			assert_not_reached ();
		}
	});

	Test.add_func ("/content_negotiation/accept_range", () => {
		var req = new Request (null, "GET", new Soup.URI ("http://localhost/"));
		var res = new Response (req);
		var ctx = new Context ();

		req.headers.append ("Accept-Range", "bytes");

		try {
			accept_ranges ("bytes", (req, res, next, ctx, ranges) => {
				assert ("bytes" == ranges);
				return true;
			}) (req, res, () => {
				assert_not_reached ();
			}, ctx);
		} catch (Error err) {
			assert_not_reached ();
		}
	});

	return Test.run ();
}
