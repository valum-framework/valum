Response
========

Responses are representing resources requested by a user agent. They are
actively streamed across the network, preferably using non-blocking
asynchronous I/O.

Status
------

The response status can be set with the ``status`` property. libsoup-2.4
provides an enumeration in `Soup.Status`_ for that purpose.

The status code will be written in the response with ``write_head`` or
``write_head_async`` if invoked manually or during the first access to its body.

.. warning::

    The response status is not initialised and not setting it will result into
    an undefined status code.

.. _Soup.Status: http://valadoc.org/#!api=libsoup-2.4/Soup.Status

::

    new Server ("org.vsgi.App", (req, res) => {
        res.status = Soup.Status.MALFORMED;
        return true;
    });

Headers
-------

The response headers can be accessed as a `Soup.MessageHeaders`_ from the
``headers`` property.

.. _Soup.MessageHeaders: http://valadoc.org/#!api=libsoup-2.4/Soup.MessageHeaders

::

    new Server ("org.vsgi.App", (req, res) => {
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

Body
----

The body of a response is accessed through the ``body`` property. It inherits
from `GLib.OutputStream`_ and provides synchronous and asynchronous streaming
capabilities.

Fixed-size body
~~~~~~~~~~~~~~~

.. versionadded:: 0.3

To deal with fixed-size body, ``expand``, ``expand_utf8`` utilities as well as
their respective asynchronous versions are provided.

It will automatically set the ``Content-Length`` header to the size of the
provided buffer, write the response head and pipe the buffer into the body
stream and close it properly.

::

    new Server ("org.vsgi.App", (req, res) => {
        res.expand_utf8 ("Hello world!");
    })

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

Asynchronous write
~~~~~~~~~~~~~~~~~~

When performing asynchronous write operations (``write_async``,
``write_all_async``, ...), the connection stream will be closed before the
response body if a reference to either the :doc:`request` or response is not
preserved until the operation ends.

The simplest thing to overcome this limitation is to reference the
:doc:`request` or response object in the asynchronous callback.

::

    new Server ("org.vsgi.App", (req, res) => {
        res.status = Soup.Status.OK;
        res.body.write_all_async.begin ("Hello world!".data,
                                        Priority.DEFAULT,
                                        null,
                                        null, (body, result) => {
            // the reference to the response has persisted
            var written = res.body.write_async.end (result);
        });
        return true;
    });

Closing the response
--------------------

The response body is automatically closed following a RAII pattern whenever the
``Connection`` object is freed. This object is held by both the :doc:`request`
and response.

You can still close the body explicitly as it can provide multiple advantages:

-  avoid further and undesired read or write operation
-  closing early let the application process outside the behalf of the user
   agent

To properly close the response, writing headers if missing, ``end`` is
provided:

::

    new Server ("org.vsgi.App", (req, res, next) => {
        res.status = Soup.Status.NO_CONTENT;
        return res.end () && next ();
    }).then ((req, res) => {
        // perform blocking operation here...
    });

If have to produce a message before closing, use ``extend`` utilities.

::

    new Server ("org.vsgi.App", (req, res) => {
        res.status = Soup.Status.OK;

        // write the message and close the body
        res.expand_utf8 ("You should receive an email shortly...");

        // perform blocking operation here...

        return true;
    });

