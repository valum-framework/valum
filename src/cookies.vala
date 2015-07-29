using GLib;
using Soup;

/**
 * Various utilities for cookies.
 *
 * @since 0.1
 */
namespace Valum.Cookies {

	/**
	 * Extract cookies from the 'Cookie' request headers.
	 *
	 * @since 0.1
	 *
	 * @param headers headers containing the cookies
	 * @param origin  origin of the cookies
	 */
	public SList<Cookie> from_request_headers (MessageHeaders headers, URI? origin= null)
#if SOUP_2_50
		ensures (headers.get_headers_type () == MessageHeadersType.REQUEST)
#endif
	{
		var cookies     = new SList<Cookie> ();
		var cookie_list = headers.get_list ("Cookie");

		if (cookie_list == null)
			return cookies;

		foreach (var cookie in cookie_list.split (","))
			if (cookie != null)
				cookies.prepend (Cookie.parse (cookie, origin));

		cookies.reverse ();

		return cookies;
	}

	/**
	 * Lookup a cookie in the request headers and return the last occurence
	 * matching the name.
	 *
	 * @since 0.2
	 *
	 * @param name    name of the cookie to lookup matched case-sensitively
	 * @param headers headers containing the request cookies
	 * @param origin  origin of the cookies
	 * @return the cookie if found, otherwise null
	 */
	public Cookie? lookup (string name, MessageHeaders headers, URI? origin = null)
#if SOUP_2_50
		ensures (headers.get_headers_type () == MessageHeadersType.REQUEST)
#endif
	{
		var cookies = Cookies.from_request_headers (headers, origin);

		cookies.reverse ();

		foreach (var cookie in cookies)
			if (cookie.name == name)
				return cookie;

		return null;
	}
}
