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

The ``Request.cookies`` property will extract cookies from the ``Cookie``
headers. Only the ``name`` and ``value`` fields will be filled as it is the
sole information sent by the client.

::

    var cookies = req.cookies;

The equivalent property exist for :doc:`response` and will extract the
``Set-Cookie`` headers instead. The corresponding :doc:`request` URI will be
used for the cookies origin.

::

    var cookies = res.cookies;

The extracted cookies can be manipulated with common `SList`_ operations.
However, they must be written back into the :doc:`response` for the changes to
be effective.

.. _SList: http://valadoc.org/#!api=glib-2.0/GLib.SList

.. warning::

    Cookies will be in their order of appearance and `SList.reverse`_ should be
    used prior to perform a lookup that respects precedence.

::

    cookies.reverse ();

    for (var cookie in cookies)
        if (cookie.name == "session")
            return cookie;

.. _Soup.Message: http://valadoc.org/#!api=libsoup-2.4/Soup.Message
.. _Soup.MessageHeaders.get_list: http://valadoc.org/#!api=libsoup-2.4/Soup.MessageHeaders.get_list
.. _SList.reverse: http://valadoc.org/#!api=glib-2.0/GLib.SList.reverse

Lookup a cookie
---------------

You can lookup a cookie by its name from a :doc:`request` using
``lookup_cookie``, ``null`` is returned if no such cookies can be found.

.. warning::

    Although this is not formally specified, cookies name are considered as
    being case-sensitive by ``CookieUtils`` utilities.

If it's signed (recommended for sessions), the equivalent
``lookup_signed_cookie`` exists.

::

    string? session_id;
    var session = req.lookup_signed_cookie ("session", ChecksumType.SHA512, "secret".data, out session_id);

Marshall a cookie
-----------------

libsoup-2.4 provides a complete implementation with the `Soup.Cookie`_ class to
represent and marshall cookies for both request and response headers.

The newly created cookie can be sent by adding a ``Set-Cookie`` header in the
:doc:`response`.

.. _Soup.Cookie: http://valadoc.org/#!api=libsoup-2.4/Soup.Cookie

::

    var cookie = new Cookie ("name", "value", "0.0.0.0", "/", 60);
    res.headers.append ("Set-Cookie", cookie.to_set_cookie_header ());

Sign and verify
---------------

Considering that cookies are persisted by the user agent, it might be necessary
to sign to prevent forgery. ``CookieUtils.sign`` and ``CookieUtils.verify``
functions are provided for the purposes of signing and verifying cookies.

.. warning::

    Be careful when you choose and store the secret key. Also, changing it will
    break any previously signed cookies, which may still be submitted by user
    agents.

It's up to you to choose what hashing algorithm and secret: ``SHA512`` is
generally recommended.

The ``CookieUtils.sign`` utility will sign the cookie in-place. It can then be
verified using ``CookieUtils.verify``.

The value will be stored in the output parameter if the verification process is
successful.

::

    CookieUtils.sign (cookie, ChecksumType.SHA512, "secret".data);

    string value;
    if (CookieUtils.verify (cookie, ChecksumType.SHA512, "secret.data", out value)) {
        // cookie's okay and the original value is stored in value
    }

The signature is computed in a way it guarantees that:

-   we have produced the value
-   we have produced the name and associated it to the value

The algorithm is the following:

::

    HMAC (checksum_type, key, HMAC (checksum_type, key, value) + name) + value

The verification process does not handle special cases like values smaller than
the hashing: cookies are either signed or not, even if their values are
incorrectly formed.

If well-formed, cookies are verified in constant-time to prevent time-based
attacks.

