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
 *
 * @since 0.3
 */
[CCode (gir_namespace = "ValumContentNegotiation", gir_version = "0.3")]
namespace Valum.ContentNegotiation {

	/**
	 * @since 0.3
	 */
	public delegate void NegotiateCallback (Request       req,
	                                        Response      res,
	                                        NextCallback  next,
	                                        Queue<Value?> stack,
	                                        string        choice) throws Error;

	/**
	 * @since 0.3
	 */
	public enum NegotiateFlags {
		/**
		 * @since 0.3
		 */
		NONE,
		/**
		 * Call the {@link Valum.NextCallback} instead of raising a
		 * {@link Valum.ClientError.NOT_ACCEPTABLE} if the request cannot be
		 * satisfied.
		 *
		 * @since 0.3
		 */
		NEXT
	}

	private double _qvalue_for_param (string header, string param) {
		var param_pos = header.last_index_of (param);

		if (param_pos == -1)
			return 0;

		var _param = header[param_pos:header.index_of_char (';', param_pos)];

		var @params = Soup.header_parse_semi_param_list (_param);

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
	 * @since 0.3
	 *
	 * @param header_name  header to negotiate
	 * @param expectations expected values, possibly with a qvalue
	 * @param forward      callback forwarding the best expectation
	 * @param flags        flags for negociating the header
	 * @param match        compare the user agent string against an expectation
	 */
	public HandlerCallback negotiate (string                  header_name,
	                                  string                  expectations,
	                                  owned NegotiateCallback forward,
	                                  NegotiateFlags          flags = NegotiateFlags.NONE,
	                                  EqualFunc<string>       match = (EqualFunc<string>) Soup.str_case_equal) {
		var _expectations = Soup.header_parse_quality_list (expectations, null);
		return (req, res, next, stack) => {
			var header = req.headers.get_list (header_name);
			if (_expectations.length () == 0)
				throw new ClientError.NOT_ACCEPTABLE ("'%s' cannot be satisfied: nothing is expected", header_name);
			if (header == null) {
				forward (req, res, next, stack, _expectations.data);
				return;
			}

			string? best_expectation = null;
			double  best_qvalue      = 0;
			foreach (var accepted in Soup.header_parse_quality_list (header, null)) {
				foreach (var expectation in _expectations) {
					var current_qvalue = _qvalue_for_param (header, accepted) * _qvalue_for_param (expectations, expectation);
					if (match (accepted, expectation) && current_qvalue > best_qvalue) {
						best_expectation = expectation;
						best_qvalue      = current_qvalue;
					}
				}
			}

			if (best_expectation != null) {
				forward (req, res, next, stack, best_expectation);
				return;
			} else if (NegotiateFlags.NEXT in flags) {
				next (req, res);
			} else {
				throw new ClientError.NOT_ACCEPTABLE ("'%s' is not satisfiable by any of '%s'.",
				                                      header_name,
				                                      expectations);
			}
		};
	}

	/**
	 * Negotiate a 'Accept' header.
	 *
	 * It understands patterns that match all types (eg. '*\/*') or subtypes
	 * (eg. 'text\/*').
	 *
	 * @since 0.3
	 */
	public HandlerCallback accept (string                  content_types,
	                               owned NegotiateCallback forward,
	                               NegotiateFlags          flags = NegotiateFlags.NONE) {
		return negotiate ("Accept", content_types, (req, res, next, stack, content_type) => {
			HashTable<string, string>? @params;
			res.headers.get_content_type (out @params);
			res.headers.set_content_type (content_type, @params);
			forward (req, res, next, stack, content_type);
		}, flags, (pattern, @value) => {
			if (pattern == "*/*")
				return true;
			// any subtype
			if (pattern.has_suffix ("/*")) {
				return Soup.str_case_equal (pattern[0:-2], @value.split ("/", 2)[0]);
			}
			return Soup.str_case_equal (pattern, @value);
		});
	}

	/**
	 * Negotiate a 'Accept-Charset' header.
	 *
	 * It understands the wildcard character '*'.
	 *
	 * On success, set the 'charset' parameter of the 'Content-Type' header. If
	 * no content type is set, it defaults to 'application/octet-stream'.
	 *
	 * @since 0.3
	 */
	public HandlerCallback accept_charset (string                  charsets,
	                                       owned NegotiateCallback forward,
	                                       NegotiateFlags          flags = NegotiateFlags.NONE) {
		return negotiate ("Accept-Charset", charsets, (req, res, next, stack, charset) => {
			HashTable<string, string> @params;
			var content_type   = res.headers.get_content_type (out @params) ?? "application/octet-stream";
			@params["charset"] = charset;
			res.headers.set_content_type (content_type, @params);
			forward (req, res, next, stack, charset);
		}, flags, (a, b) => { return a == "*" || Soup.str_case_equal (a, b); });
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
	 *
	 * @since 0.3
	 */
	public HandlerCallback accept_encoding (string                  encodings,
	                                        owned NegotiateCallback forward,
	                                        NegotiateFlags          flags = NegotiateFlags.NONE) {
		return negotiate ("Accept-Encoding", encodings, (req, res, next, stack, encoding) => {
			res.headers.append ("Content-Encoding", encoding);
			switch (encoding.down ()) {
				case "gzip":
					forward (req,
					         new ConvertedResponse (res, new ZlibCompressor (ZlibCompressorFormat.GZIP)),
					         next,
					         stack,
					         encoding);
					break;
				case "deflate":
					forward (req,
					         new ConvertedResponse (res, new ZlibCompressor (ZlibCompressorFormat.ZLIB)),
					         next,
					         stack,
					         encoding);
					break;
				case "identity":
					forward (req, res, next, stack, encoding);
					break;
				default:
					break;
			}
		}, flags, (a, b) => { return a == "*" || Soup.str_case_equal (a, b); });
	}

	/**
	 * Negotiate a 'Accept-Language' header.
	 *
	 * If the user agent does not have regional preferences (eg. 'Accept: en'),
	 * then any regional variation will be considered acceptable.
	 *
	 * @since 0.3
	 */
	public HandlerCallback accept_language (string                  languages,
	                                        owned NegotiateCallback forward,
	                                        NegotiateFlags          flags = NegotiateFlags.NONE) {
		return negotiate ("Accept-Language", languages, (req, res, next, stack, language) => {
			res.headers.replace ("Content-Language", language);
			forward (req, res, next, stack, language);
		}, flags, (a, b) => {
			if (a == "*")
				return true;
			// exclude the regional part
			if (!a.contains ("-"))
				return Soup.str_case_equal (a, b.split ("-", 2)[0]);
			return a == "*" || Soup.str_case_equal (a, b);
		});
	}

	/**
	 * Negotiate a 'Accept-Range' header.
	 *
	 * This is typically used with the 'bytes' value.
	 *
	 * @since 0.3
	 */
	public HandlerCallback accept_ranges (string                  ranges,
	                                      owned NegotiateCallback forward,
	                                      NegotiateFlags          flags = NegotiateFlags.NONE) {
		return negotiate ("Accept-Ranges", ranges, (owned) forward, flags);
	}
}
