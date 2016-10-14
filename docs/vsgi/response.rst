Response
========

Responses are representing resources requested by a user agent. They are
actively streamed across the network, preferably using non-blocking
asynchronous I/O.

Status
------

The response status can be set with the ``status`` property. libsoup-2.4
provides an enumeration in :valadoc:`libsoup-2.4/Soup.Status` for that purpose.

The ``status`` property will default to ``200 OK``.

The status code will be written in the response with ``write_head`` or
``write_head_async`` if invoked manually or during the first access to its
body.

::

    Server.new_with_application ("http", (req, res) => {
        res.status = Soup.Status.MALFORMED;
        return true;
    });

Reason phrase
-------------

.. versionadded:: 0.3

The reason phrase provide a textual description for the status code. If
``null``, which is the default, it will be generated using
:valadoc:`libsoup-2.4/Soup.Status.get_phrase`.

::

    Server.new_with_application ("http", (req, res) => {
        res.status = Soup.Status.OK;
        res.reason_phrase = "Everything Went Well"
        return true;
    });

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

The response headers can be accessed as a :valadoc:`libsoup-2.4/Soup.MessageHeaders`
from the ``headers`` property.

::

    Server.new_with_application ("http", (req, res) => {
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
from :valadoc:`gio-2.0/GLib.OutputStream` and provides synchronous and
asynchronous streaming capabilities.

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

    Server.new_with_application ("http", (req, res) => {
        res.expand_utf8 ("Hello world!");
    });

Filtering
~~~~~~~~~

One common operation related to stream is filtering. :valadoc:`gio-2.0/GLib.FilterOutputStream`
and :valadoc:`gio-2.0/GLib.ConverterOutputStream` provide, by composition, many
filters that can be used for:

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
header is set. The obtained :valadoc:`gio-2.0/GLib.OutputStream` will be
wrapped appropriately so that the application can transparently produce its
output.

::

    res.headers.append ("Transfer-Encoding", "chunked");
    return res.body.write_all ("Hello world!".data, null);

Conversion
~~~~~~~~~~

.. versionadded:: 0.3

The body may be converted, see :doc:`converters` for more details.

Tee
---

.. versionadded:: 0.3

The response body can be splitted pretty much like how the ``tee`` UNIX utility
works. All further write operations will be performed as well on the passed
stream, making it possible to process the payload sent to the user agent.

The typical use case would be to implement a file-based cache that would tee
the produced response body into a key-based storage.

::

    var cache_key   = Checksum.compute_for_string (ChecksumType.SHA256, req.uri.to_string ());
    var cache_entry = File.new_for_path ("cache/%s".printf (cache_key));

    if (cache_entry.query_exists ()) {
        return res.body.splice (cache_entry.read ());
    } else {
        res.tee (cache_entry.create (FileCreateFlags.PRIVATE));
    }

    res.exand_utf8 ("Hello world!");

End
---

.. versionadded:: 0.3

To properly close the response, writing headers if missing, ``end`` is
provided:

::

    Server.new_with_application ("http", (req, res, next) => {
        res.status = Soup.Status.NO_CONTENT;
        return res.end () && next ();
    }).then ((req, res) => {
        // perform blocking operation here...
    });

To produce a message before closing, favour ``extend`` utilities.

