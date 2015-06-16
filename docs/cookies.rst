Cookies
=======

HTTP cookies are stored in :doc:`vsgi/request` and :doc:`vsgi/response`
headers.

Various cookies utilities are provided in the ``Cookies`` namespace to
compensate the fact that libsoup-2.4 utilities requires a `Soup.Message`_,
which is not available in other VSGI implementations.

They can be extracted as a singly-linked list from a request headers and an
optional origin URI in their order of appearance (see `Soup.MessageHeaders.get_list`_ for more details).

`SList.reverse`_ can be used to invert the order of cookies and respect the
precedence.

.. _Soup.Message: http://valadoc.org/#!api=libsoup-2.4/Soup.Message
.. _Soup.MessageHeaders.get_list: http://valadoc.org/#!api=libsoup-2.4/Soup.MessageHeaders.get_list
.. _SList.reverse: http://valadoc.org/#!api=glib-2.0/GLib.SList.reverse

.. code:: vala

    var cookies = Cookies.from_request_headers (req.headers, req.uri);

    cookies.reverse ();

    // obtain the last 'session' cookie
    foreach (var cookie in cookies)
        if (cookie.name == "session")
            return cookie.value;

libsoup-2.4 provides a complete implementation with `Soup.Cookie`_ that can be
used to create a new cookie.

.. _Soup.Cookie: http://valadoc.org/#!api=libsoup-2.4/Soup.Cookie

.. code:: vala

    var cookie = new Cookie ("name", "value", "0.0.0.0", "/", 60);
    res.headers.append ("Set-Cookie", cookie.to_set_cookie_header ());
