Response
========

Responses are representing resources requested by a user agent. They are
actively streamed across the network, preferably using non-blocking
asynchronous I/O.

Status
------

The response status can be set with the ``status`` property. libsoup-2.4
provides an enumeration in `Soup.Status`_ for that purpose.

The ``status`` property will default to ``200 OK``.

The status code will be written in the response with ``write_head`` or
``write_head_async`` if invoked manually or during the first access to its
body.

.. _Soup.Status: http://valadoc.org/#!api=libsoup-2.4/Soup.Status

::

    Server.new_with_application ("http", "org.vsgi.App", (req, res) => {
        res.status = Soup.Status.MALFORMED;
        return true;
    });

Reason phrase
-------------

.. versionadded:: 0.3

The reason phrase provide a textual description for the status code. If
``null``, which is the default, it will be generated using `Soup.Status.get_phrase`_.

::

    Server.new_with_application ("http", "org.vsgi.App", (req, res) => {
        res.status = Soup.Status.OK;
        res.reason_phrase = "Everything Went Well"
        return true;
    });

.. _Soup.Status.get_phrase: http://valadoc.org/#!api=libsoup-2.4/Soup.Status.get_phrase

To obtain final status line sent to the user agent, use the ``wrote_status_line``
signal.

::

    res.wrote_status_line.connect ((http_version, status, reason_phrase) => {
        if (200 <= status < 300) {
            // assuming a success
        }
    });

Headers
-------

The response headers can be accessed as a `Soup.MessageHeaders`_ from the
``headers`` property.

.. _Soup.MessageHeaders: http://valadoc.org/#!api=libsoup-2.4/Soup.MessageHeaders

::

    Server.new_with_application ("http", "org.vsgi.App", (req, res) => {
        res.status = Soup.Status.OK;
        res.headers.set_content_type ("text/plain", null);
        return res.body.write_all ("Hello world!".data, null);
    });

Headers can be written in the response by invoking ``write_head`` or its
asynchronous version ``write_head_async``. The synchronous version is called
automatically when the body is accessed for the first time.

::

    res.write_head_async.begin (Priority.DEFAULT, null, () => {
        // produce the body...
    });

.. warning::

    Once written, any modification to the ``headers`` object will be ignored.

The ``head_written`` property can be tested to see if it's already the case,
even though a well written application should assume that already.

::

    if (!res.head_written) {
        res.headers.set_content_type ("text/html", null);
    }

Since headers can still be modified once written, the ``wrote_headers`` signal
can be used to obtain definitive values.

::

    res.wrote_headers (() => {
        foreach (var cookie in res.cookies) {
            message (cookie.to_set_cookie_header ());
        }
    });

Body
----

The body of a response is accessed through the ``body`` property. It inherits
from `GLib.OutputStream`_ and provides synchronous and asynchronous streaming
capabilities.

It's also possible to obtain the body asynchronously as it might trigger
a blocking call call to ``write_head``.

::

    res.get_body_async.begin (Priority.DEFAULT, null, (obj, result) => {
        var body = res.get_body_async.end (result);
        body.write_all ("Hello world!".data, null);
    });

The response body is automatically closed following a RAII pattern whenever the
``Response`` object is disposed.

Note that a reference to the body is not sufficient to maintain the inner
:doc:`connection` alive: a reference to either the :doc:`request` or response
be maintained.

You can still close the body early as it can provide multiple advantages:

-  avoid further and undesired read or write operation
-  indicate to the user agent that the body has been fully sent

Expand
~~~~~~

.. versionadded:: 0.3

To deal with fixed-size body, ``expand``, ``expand_bytes`` and ``expand_utf8``
utilities as well as their respective asynchronous versions are provided.

It will automatically set the ``Content-Length`` header to the size of the
provided buffer, write the response head and pipe the buffer into the body
stream and close it properly.

::

    Server.new_with_application ("http", "org.vsgi.App", (req, res) => {
        res.expand_utf8 ("Hello world!");
    });

Filtering
~~~~~~~~~

One common operation related to stream is filtering. `GLib.FilterOutputStream`_
and `GLib.ConverterOutputStream`_ provide, by composition, many filters that
can be used for:

 - compression and decompression (gzip, deflate, compress, ...)
 - charset conversion
 - buffering
 - writting data

VSGI also provides its own set of :doc:`converters` which cover parts of the
HTTP/1.1 specifications such as chunked encoding.

::

    var body = new ConverterOutputStream (res.body,
                                          new CharsetConverter (res.body, "iso-8859-1", "utf-8"));

    return body.write_all ("Omelette du fromâge!", null);

Additionally, some filters are applied automatically if the ``Transfer-Encoding``
header is set. The obtained `GLib.OutputStream`_ will be wrapped appropriately
so that the application can transparently produce its output.

.. _GLib.OutputStream: http://valadoc.org/#!api=gio-2.0/GLib.OutputStream
.. _GLib.FilterOutputStream: http://valadoc.org/#!api=gio-2.0/GLib.FilterOutputStream
.. _GLib.ConverterOutputStream: http://valadoc.org/#!api=gio-2.0/GLib.ConverterOutputStream

::

    res.headers.append ("Transfer-Encoding", "chunked");
    return res.body.write_all ("Hello world!".data, null);

Conversion
~~~~~~~~~~

.. versionadded:: 0.3

The body may be converted, see :doc:`converters` for more details.

End
---

.. versionadded:: 0.3

To properly close the response, writing headers if missing, ``end`` is
provided:

::

    Server.new_with_application ("http", "org.vsgi.App", (req, res, next) => {
        res.status = Soup.Status.NO_CONTENT;
        return res.end () && next ();
    }).then ((req, res) => {
        // perform blocking operation here...
    });

To produce a message before closing, favour ``extend`` utilities.

