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
using VSGI;

/**
 * Content negociation for various headers.
 */
[CCode (gir_namespace = "Valum", gir_version = "0.3")]
namespace Valum.ContentNegotiation {

	private double _qvalue_for_param (string header, string param) {
		var param_start = header.last_index_of (param);

		if (param_start == -1)
			return 0;

		var param_end = header.index_of_char (',', param_start);

		if (param_end == -1)
			param_end = header.length;

		var @params = Soup.header_parse_semi_param_list (header[param_start:param_end]);

		double qvalue;
		if (double.try_parse (@params["q"] ?? "1", out qvalue)) {
			return qvalue.clamp (0, 1);
		}

		return 0;
	}

	/**
	 * Negotiate a HTTP header against a set of expectations.
	 *
	 * The header is extracted as a quality list and a lookup is performed to
	 * see if the expected value is accepted by the user agent.
	 *
	 * The expectation is selected such that it maximize the product of the
	 * quality and user agent preference. For equal values, user agent
	 * preferences are considered first, then expectations.
	 *
	 * If the header is not provided in the request, it is assumed that the user
	 * agent consider any response as acceptable: the expectation with the
	 * highest quality will be forwarded.
	 *
	 * If more than one expectations is supplied, the 'Vary' header with the
	 * negotiated header name will be appended to the response headers to
	 * indicate that the resource has been generated based on its value.
	 *
	 * @param header_name  header to negotiate
	 * @param expectations expected values, possibly with a qvalue
	 * @param forward      callback forwarding the best expectation
	 * @param match        compare the user agent string against an expectation
	 */
	[Version (since = "0.3")]
	public HandlerCallback negotiate (string                        header_name,
	                                  string                        expectations,
	                                  owned ForwardCallback<string> forward = Valum.forward,
	                                  EqualFunc<string>             match   = (EqualFunc<string>) Soup.str_case_equal) {
		var _expectations = Soup.header_parse_quality_list (expectations, null);
		return (req, res, next, ctx) => {
			var header = req.headers.get_list (header_name);

			if (_expectations.length () == 0) {
				throw new ClientError.NOT_ACCEPTABLE ("'%s' cannot be satisfied: nothing is expected.", header_name);
			}

			if (_expectations.length () > 1) {
				var vary = res.headers.get_list ("Vary") ??  "";
				if (Soup.header_parse_list (vary).find_custom (header_name, (a, b) => { return Soup.str_case_equal (a, b) ? 0 : 1; }) == null) {
					res.headers.append ("Vary", header_name);
				}
			}

			if (header == null) {
				return forward (req, res, next, ctx, _expectations.data);
			}

			string?       best_expectation = null;
			double        best_qvalue      = 0;
			SList<string> unacceptable;
			foreach (var accepted in Soup.header_parse_quality_list (header, out unacceptable)) {
				foreach (var expectation in _expectations) {
					if (unacceptable.find_custom (expectation, (a, b) => { return Soup.str_case_equal (a, b) ? 0 : 1; }) == null) {
						var current_qvalue = _qvalue_for_param (header, accepted) * _qvalue_for_param (expectations, expectation);
						if (match (accepted, expectation) && current_qvalue > best_qvalue) {
							best_expectation = expectation;
							best_qvalue      = current_qvalue;
						}
					}
				}
			}

			if (best_expectation != null) {
				return forward (req, res, next, ctx, best_expectation);
			}

			throw new ClientError.NOT_ACCEPTABLE ("'%s' is not satisfiable by any of '%s'.",
												  header_name,
												  expectations);
		};
	}

	/**
	 * Negotiate a 'Accept' header.
	 *
	 * It understands patterns that match all types (eg. '*\/*'), subtypes
	 * (eg. 'text\/*') and compound subtypes (eg. 'application/vnd.api+json')
	 *
	 * For compound subtypes, it checks if the accepted subtypes by the user
	 * agent form a subset of the proposed ones. Note that the '*' subtype is
	 * always considered acceptable.
	 */
	[Version (since = "0.3")]
	public HandlerCallback accept (string                        content_types,
	                               owned ForwardCallback<string> forward = Valum.forward) {
		return negotiate ("Accept", content_types, (req, res, next, ctx, content_type) => {
			HashTable<string, string>? @params;
			res.headers.get_content_type (out @params);
			res.headers.set_content_type (content_type, @params);
			return forward (req, res, next, ctx, content_type);
		}, (pattern, @value) => {
			var pattern_type = pattern.slice (0, pattern.index_of_char ('/'));
			var type         = @value.slice (0, @value.index_of_char ('/'));

			// check the type
			if (pattern_type != "*" && !Soup.str_case_equal (pattern_type, type)) {
				return false;
			}

			var pattern_subtypes = pattern.slice (pattern.index_of_char ('/') + 1, pattern.length).split ("+");
			var subtypes         = @value.slice (@value.index_of_char ('/') + 1, @value.length).split ("+");

			// check the subtypes, which can be compound: it has to form a subset
			// of the proposed types
			foreach (var pattern_subtype in pattern_subtypes) {
				var accepted = false;

				foreach (var subtype in subtypes) {
					accepted |= pattern_subtype == "*" || Soup.str_case_equal (pattern_subtype, subtype);
				}

				// one accepted subtype could not be satisfied
				if (!accepted) {
					return false;
				}
			}

			return true;
		});
	}

	/**
	 * Negotiate a 'Accept-Charset' header.
	 *
	 * It understands the wildcard character '*'.
	 *
	 * On success, set the 'charset' parameter of the 'Content-Type' header. If
	 * no content type is set, it defaults to 'application/octet-stream'.
	 */
	[Version (since = "0.3")]
	public HandlerCallback accept_charset (string                        charsets,
	                                       owned ForwardCallback<string> forward = Valum.forward) {
		return negotiate ("Accept-Charset", charsets, (req, res, next, ctx, charset) => {
			HashTable<string, string> @params;
			var content_type   = res.headers.get_content_type (out @params) ?? "application/octet-stream";
			if (@params == null) {
				@params = new HashTable<string, string> ((GLib.HashFunc<string>) Soup.str_case_hash,
				                                         (GLib.EqualFunc<string>) Soup.str_case_equal);
			}
			@params["charset"] = charset;
			res.headers.set_content_type (content_type, @params);
			return forward (req, res, next, ctx, charset);
		}, (a, b) => { return a == "*" || Soup.str_case_equal (a, b); });
	}

	/**
	 * Negotiate a 'Accept-Encoding' header.
	 *
	 * It understands the wildcard '*'.
	 *
	 * This must be applied before any other content negotiation as it might
	 * convert the response to honor the negotiated encoding.
	 *
	 * The 'gzip', 'deflate' and 'identity' encodings are handled. Other
	 * encodings must be handled manually.
	 */
	[Version (since = "0.3")]
	public HandlerCallback accept_encoding (string                        encodings,
	                                        owned ForwardCallback<string> forward = Valum.forward) {
		return negotiate ("Accept-Encoding", encodings, (req, res, next, ctx, encoding) => {
			res.headers.append ("Content-Encoding", encoding);
			switch (encoding.down ()) {
				case "gzip":
					res.convert (new ZlibCompressor (ZlibCompressorFormat.GZIP));
					return forward (req, res, next, ctx, encoding);
				case "deflate":
					res.convert (new ZlibCompressor (ZlibCompressorFormat.ZLIB));
					return forward (req, res, next, ctx, encoding);
				case "identity":
					return forward (req, res, next, ctx, encoding);
				default:
					throw new ServerError.NOT_IMPLEMENTED ("The '%s' encoding is not supported.", encoding);
			}
		}, (a, b) => {
			return a == "*"                            ||
			       Soup.str_case_equal (a, b)          ||
			       Soup.str_case_equal ("identity", b) ||
			       (a.has_prefix ("x-") && Soup.str_case_equal (a[2:a.length], b));
		});
	}

	/**
	 * Negotiate a 'TE' header.
	 *
	 * Unlike for {@link Valum.ContentNegotiation.accept_encoding}, the transfer
	 * coding is not applied with a {@link GLib.Converter}, but simply stated in
	 * the response headers. It's up to the VSGI implementation to perform that
	 * work.
	 *
	 * Note that according to HTTP/1.1 specification, the 'chunked' encoding is
	 * always considered acceptable.
	 */
	[Version (since = "0.3")]
	public HandlerCallback accept_transfer_encoding (string                        encodings,
	                                                 owned ForwardCallback<string> forward = Valum.forward) {
		return negotiate ("TE", encodings, (req, res, next, ctx, encoding) => {
			res.headers.append ("Transfer-Encoding", encoding);
			return forward (req, res, next, ctx, encoding);
		}, (a, b) => {
			return a == "*"                            ||
			       Soup.str_case_equal (a, b)          ||
			       Soup.str_case_equal ("identity", b) ||
			       Soup.str_case_equal ("chunked", b)  || // always acceptable
			       (a.has_prefix ("x-") && Soup.str_case_equal (a[2:a.length], b));
		});
	}

	/**
	 * Negotiate a 'Accept-Language' header.
	 *
	 * If the user agent have regional preferences (eg. 'Accept: en-GB'),
	 * then any non-regional variation will be considered acceptable.
	 */
	[Version (since = "0.3")]
	public HandlerCallback accept_language (string                        languages,
	                                        owned ForwardCallback<string> forward = Valum.forward) {
		return negotiate ("Accept-Language", languages, (req, res, next, ctx, language) => {
			res.headers.replace ("Content-Language", language);
			return forward (req, res, next, ctx, language);
		}, (a, b) => {
			if (a == "*")
				return true;
			// exclude the regional part
			if (a.contains ("-"))
				return Soup.str_case_equal (a.split ("-", 2)[0], b);
			return Soup.str_case_equal (a, b);
		});
	}

	/**
	 * Negotiate a 'Accept-Range' header.
	 *
	 * This is typically used with the 'bytes' value.
	 */
	[Version (since = "0.3")]
	public HandlerCallback accept_ranges (string                        ranges,
	                                      owned ForwardCallback<string> forward = Valum.forward) {
		return negotiate ("Accept-Ranges", ranges, (owned) forward);
	}
}
