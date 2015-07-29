Cookies
=======

Cookies are stored in :doc:`vsgi/request` and :doc:`vsgi/response` headers as
part of the HTTP protocol.

Utilities are provided to perform basic operations based on `Soup.Cookie`_ as
those provided by libsoup-2.4 requires a `Soup.Message`_, which is not common
to all implementations.

-  extract cookies from request headers
-  find a cookie by its name
-  marshall cookies for request or response headers (provided by libsoup-2.4)

Extract all cookies
-------------------

Cookies can be extracted as a singly-linked list from a request headers and an
optional origin URI in their order of appearance (see `Soup.MessageHeaders.get_list`_ for more details)
using ``Cookies.from_request_headers``.

.. code:: vala

    var cookies = Cookies.from_request_headers (req.headers, req.uri);

`SList.reverse`_ can be used to invert the order of cookies and respect the
precedence if you want to lookup a specific cookie.

.. _Soup.Message: http://valadoc.org/#!api=libsoup-2.4/Soup.Message
.. _Soup.MessageHeaders.get_list: http://valadoc.org/#!api=libsoup-2.4/Soup.MessageHeaders.get_list
.. _SList.reverse: http://valadoc.org/#!api=glib-2.0/GLib.SList.reverse

Lookup a cookie
---------------

You can lookup a cookie by its name using ``Cookies.lookup``, the request
headers and an optional origin URI.

.. warning::

    Although this is not formally specified, cookies name are considered as
    being case-sensitive by ``Cookies`` utilities.

This feature is provided by ``Cookies.lookup``, ``null`` is returned if no such
cookies has been found.

.. code:: vala

    var session = Cookies.lookup ("session", req.headers, req.uri);

Marshall a cookie
-----------------

libsoup-2.4 provides a complete implementation with the `Soup.Cookie`_ class to
represent and marshall cookies for both request and response headers.

The newly created cookie can be sent by adding a ``Set-Cookie`` header in the
:doc:`vsgi/response`.

.. _Soup.Cookie: http://valadoc.org/#!api=libsoup-2.4/Soup.Cookie

.. code:: vala

    var cookie = new Cookie ("name", "value", "0.0.0.0", "/", 60);
    res.headers.append ("Set-Cookie", cookie.to_set_cookie_header ());
