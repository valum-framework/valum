Request
=======

Requests are representing incoming demands from user agents to resources served
by an application.

Method
------

.. deprecated:: 0.3

    libsoup-2.4 provide an enumeration of valid HTTP methods and this will be
    removed once exposed in their Vala API.

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

::

    if (req.method == Request.GET) {
        return res.expand_utf8 ("Hello world!");
    }

    if (req.method == Request.POST) {
        return res.body.splice (req.body, OutputStreamSpliceFlags.NONE);
    }

    if (req.method in Request.METHODS) {
        // handle a standard HTTP method...
    }

Headers
-------

Request headers are implemented with :valadoc:`libsoup-2.4/Soup.MessageHeaders`
and can be accessed from the ``headers`` property.

::

    Server.new_with_application ("http", (req) => {
        var accept = req.headers.get_one ("Accept");
        return true;
    });

libsoup-2.4 provides a very extensive set of utilities to process the
information contained in headers.

::

    SList<string> unacceptable;
    Soup.header_parse_quality_list (req.headers.get_list ("Accept"), out unacceptable);

Cookies
~~~~~~~

:doc:`cookies` can also be retrieved from the request headers.

Query
-----

The HTTP query is provided in various way:

 - parsed as a ``HashTable<string, string>?`` through the ``Request.query``
   property
 - raw with ``Request.uri.get_query``

If the query is not provided (e.g. no ``?`` in the URI), then the
``Request.query`` property will take the ``null`` value.

.. note::

    If the query is not encoded according to ``application/x-www-form-urlencoded``,
    it has to be parsed explicitly.

To safely obtain a value from the HTTP query, use ``Request.lookup_query`` with
the null-coalescing operator ``??``.

::

    req.lookup_query ("key") ?? "default value";

Body
----

The body is provided as a :valadoc:`gio-2.0/GLib.InputStream` by the ``body``
property. The stream is transparently decoded from any applied transfer
encodings.

Implementation will typically consume the status line, headers and newline that
separates the headers from the body in the base stream at construct time. It
also guarantee that the body has been decoded if any transfer encoding were
applied for the transport.

If the content is encoded with the ``Content-Encoding`` header, it is the
responsibility of your application to decode it properly. VSGI provides common
:doc:`converters` to simplify the task.

Flatten
~~~~~~~

.. versionadded:: 0.2.4

In some cases, it is practical to flatten the whole request body in a buffer
in order to process it as a whole.

The ``flatten``, ``flatten_bytes`` and ``flatten_utf8`` functions accumulate
the request body into a buffer (a :valadoc:`gio-2.0/GLib.MemoryOutputStream`)
and return the corresponding ``uint8[]`` data buffer.

The request body is always fixed-size since the HTTP specification requires any
request to provide a ``Content-Length`` header. However, the environment should
be configured with a hard limit on payload size.

When you are done, it is generally a good thing to close the request body and
depending on the used implementation, this could have great benefits such as
freeing a file resource.

::

    Server.new_with_application ("http", (req, res) => {
        var payload = req.flatten ();
        return true;
    });

Form
~~~~

:valadoc:`libsoup-2.4/Soup.Form` can be used to parse ``application/x-www-form-urlencoded``
format, which is submitted by web browsers.

::

    Server.new_with_application ("http", (req, res) => {
        var data = Soup.Form.decode (req.flatten_utf8 (out bytes_read));
        return true;
    });

Multipart body
~~~~~~~~~~~~~~

Multipart body support is planned in a future minor release, more information
on `issue #81`_. The implementation will be similar to :valadoc:`libsoup-2.4/Soup.MultipartInputStream`
and provide part access with a filter approach.

.. _issue #81: https://github.com/valum-framework/valum/issues/81

