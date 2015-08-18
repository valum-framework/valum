Request
=======

Requests are representing incoming demands from user agents to resources served
by an application.

Method
------

The ``Request`` class provides constants for the following HTTP methods:

-  ``OPTIONS``
-  ``GET``
-  ``HEAD``
-  ``POST``
-  ``PUT``
-  ``DELETE``
-  ``TRACE``
-  ``CONNECT``
-  ``PATCH``

Additionally, an array of supported HTTP methods is provided by
``Request.METHODS``.

.. code:: vala

    if (req.method == Request.GET) {
        res.body.write_all ("Hello world!".data, null);
    }

    if (req.method == Request.POST) {
        res.body.splice (req.body, OutputStreamSpliceFlags.CLOSE_SOURCE);
    }

    if (req.method in Request.METHODS) {
        // handle a standard HTTP method...
    }

Request parameters
------------------

.. deprecated:: 0.2

    Use the routing stack described in the :doc:`../router` documentation.

The request parameters are stored in a `GLib.HashTable`_ of ``string`` to
``string`` and can be accessed from the ``Request.params`` property. It's used
as a general metadata storage for requests.

.. _Glib.HashTable: http://valadoc.org/#!api=glib-2.0/GLib.HashTable

.. code:: vala

    app.get ("<int:id>", (req, res) => {
        var id = req.params["id"];
    });

It is used to store named captures from rule and regular expression
:doc:`../route` and as a general storage for custom matcher.

Request parameters are metadata extracted by the ``Route.MatcherCallback`` that
matched the request you are handling. They can contain pretty much anything
since a matcher can be any function accepting a ``Request`` instance.

The parameter defaults to ``null`` if it is not populated.

.. code:: vala

    new Server ("org.vsgi.App", (req) => {
        // req.params == null
    });

Headers
-------

Request headers are implemented with `Soup.MessageHeaders`_ and can be accessed
from the ``headers`` property.

.. _Soup.MessageHeaders: http://valadoc.org/#!api=libsoup-2.4/Soup.MessageHeaders

.. code:: vala

    new Server ("org.vsgi.App", (req) => {
        var accept = req.headers.get_one ("Accept");
    });

libsoup-2.4 provides a very extensive set of utilities to process the
information contained in headers.

.. code:: vala

    SList<string> unacceptable;
    Soup.header_parse_quality_list (req.headers.get_list ("Accept"), out unacceptable);

Body
----

The body is provided as a `GLib.InputStream`_ by the ``body`` property. The
stream is transparently decoded from any applied transfer encodings.

Implementation will typically consume the status line, headers and newline that
separates the headers from the body in the base stream at construct time. It
also guarantee that the body has been decoded if any transfer encoding were
applied for the transport.

If the content is encoded with the ``Content-Encoding`` header, it is the
responsibility of your application to decode it properly. VSGI provides common
:doc:`converters` to simplify the task.

.. _GLib.InputStream: http://valadoc.org/#!api=gio-2.0/GLib.InputStream

Form
~~~~

`Soup.Form`_ can be used to parse ``application/x-www-form-urlencoded`` format,
which is submitted by web browsers.

.. _Soup.Form: http://valadoc.org/#!api=libsoup-2.4/Soup.Form

.. code:: vala

    new Server ("org.vsgi.App", (req, res) => {
        var buffer = new MemoryOutputStream.resizable ();

        // consume the request body in the stream
        buffer.splice (req.body, OutputStreamSpliceFlags.CLOSE_SOURCE);

        // consume it asynchronously
        buffer.splice_async.begin (req.body,
                                   OutputStreamSpliceFlags.CLOSE_SOURCE,
                                   Priority.DEFAULT,
                                   null,
                                   (obj, result) => {
            var consumed = buffer.splice_async.end (result);

            // decode the data
            var data = Soup.Form.decode (buffer.data);
        })
    });

.. _GLib.CharsetConverter: http://valadoc.org/#!api=gio-2.0/GLib.CharsetConverter.CharsetConverter

Multipart body
~~~~~~~~~~~~~~

Multipart body support is planned in a future minor release, more information
on `issue #81`_. The implementation will be similar to `Soup.MultipartInputStream`_
and provide part access with a filter approach.

.. _issue #81: https://github.com/valum-framework/valum/issues/81
.. _Soup.MultipartInputStream: http://valadoc.org/#!api=libsoup-2.4/Soup.MultipartInputStream.MultipartInputStream

Closing the request
-------------------

When you are done, it is generally a good thing to close the request and
depending on the VSGI implementations, this could have great benefits such as
freeing a file resource.

