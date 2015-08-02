Cookies
=======

Cookies are stored in :doc:`request` and :doc:`response` headers as
part of the HTTP protocol.

Utilities are provided to perform basic operations based on `Soup.Cookie`_ as
those provided by libsoup-2.4 requires a `Soup.Message`_, which is not common
to all implementations.

-  extract cookies from request headers
-  find a cookie by its name
-  marshall cookies for request or response headers (provided by libsoup-2.4)

Extract cookies
---------------

Cookies can be extracted as a singly-linked list from a :doc:`request` or
:doc:`response` their order of appearance (see `Soup.MessageHeaders.get_list`_
for more details).

``Cookies.from_request`` will extract cookies from the ``Cookie`` headers. Only
the ``name`` and ``value`` fields will be filled as it is the sole information
sent by the client.

.. code:: vala

    var cookies = Cookies.from_request (req);

The equivalent utility exist for :doc:`response` and will extract the
``Set-Cookie`` headers instead. The corresponding :doc:`request` URI will be
used for the cookies origin.

.. code:: vala

    var cookies = Cookies.from_response (res);

The extracted cookies can be manipulated with common `SList`_ operations.

.. _SList: http://valadoc.org/#!api=glib-2.0/GLib.SList

.. warning::

    Cookies will be in their order of appearance and `SList.reverse`_ should be
    used prior to perform a lookup that respects precedence.

.. code:: vala

    cookies.reverse ();

    for (var cookie in cookies)
        if (cookie.name == "session")
            return cookie;

.. _Soup.Message: http://valadoc.org/#!api=libsoup-2.4/Soup.Message
.. _Soup.MessageHeaders.get_list: http://valadoc.org/#!api=libsoup-2.4/Soup.MessageHeaders.get_list
.. _SList.reverse: http://valadoc.org/#!api=glib-2.0/GLib.SList.reverse

Lookup a cookie
---------------

You can lookup a cookie by its name from a ``SList<Cookie>`` using
``Cookies.lookup``, ``null`` is returned if no such cookies can be found.

.. warning::

    Although this is not formally specified, cookies name are considered as
    being case-sensitive by ``Cookies`` utilities.

.. code:: vala

    var session = Cookies.lookup (cookies, "session");

Marshall a cookie
-----------------

libsoup-2.4 provides a complete implementation with the `Soup.Cookie`_ class to
represent and marshall cookies for both request and response headers.

The newly created cookie can be sent by adding a ``Set-Cookie`` header in the
:doc:`response`.

.. _Soup.Cookie: http://valadoc.org/#!api=libsoup-2.4/Soup.Cookie

.. code:: vala

    var cookie = new Cookie ("name", "value", "0.0.0.0", "/", 60);
    res.headers.append ("Set-Cookie", cookie.to_set_cookie_header ());
