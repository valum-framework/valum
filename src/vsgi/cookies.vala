using Soup;

namespace VSGI.Cookies {

	/**
	 * Extract cookies from the 'Cookie' headers.
	 *
	 * @since 0.2
	 *
	 * @param request
	 */
	public SList<Cookie> from_request (Request request) {
		var cookies     = new SList<Cookie> ();
		var cookie_list = request.headers.get_list ("Cookie");

		if (cookie_list == null)
			return cookies;

		foreach (var cookie in cookie_list.split (","))
			if (cookie != null)
				cookies.prepend (Cookie.parse (cookie, null));

		cookies.reverse ();

		return cookies;
	}

	/**
	 * Extract cookies from the 'Set-Cookie' headers.
	 *
	 * @since 0.2
	 *
	 * @param response
	 */
	public SList<Cookie> from_response (Response response) {
		var cookies     = new SList<Cookie> ();
		var cookie_list = response.headers.get_list ("Set-Cookie");

		if (cookie_list == null)
			return cookies;

		foreach (var cookie in cookie_list.split (","))
			if (cookie != null)
				cookies.prepend (Cookie.parse (cookie, response.request.uri));

		cookies.reverse ();

		return cookies;
	}

	/**
	 * Lookup a cookie by its name.
	 *
	 * The last occurence is returned using a case-sensitive match.
	 *
	 * @since 0.2
	 *
	 * @param cookies cookies typically extracted from {@link VSGI.Cookies.from_request}
	 * @param name    name of the cookie to lookup
	 * @return the cookie if found, otherwise null
	 */
	public Cookie? lookup (SList<Cookie> cookies, string name) {
		Cookie? found = null;

		foreach (var cookie in cookies)
			if (cookie.name == name)
				found = cookie;

		return found;
	}
}
