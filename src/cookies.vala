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
	 * @param uri     origin of the cookies
	 */
	public SList<Cookie> from_request_headers (MessageHeaders headers, URI? uri = null)
#if SOUP_2_50
		ensures (headers.get_headers_type () == MessageHeadersType.REQUEST)
#endif
	{
		var cookies     = new SList<Cookie> ();
		var cookie_list = headers.get_list ("Cookie");

		if (cookie_list == null)
			return cookies;

		foreach (var cookie in cookie_list.split ("; ")) {
			if (cookie != null)
				cookies.prepend (Cookie.parse (cookie, uri));
		}

		cookies.reverse ();

		return cookies;
	}
}
