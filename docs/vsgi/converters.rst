Converters
==========

VSGI provide stream utilities named converters to convert data according to
modern web standards.

These are particularly useful to encode and recode request and response bodies
in VSGI implementations.

GLib provide default convertors for charset conversion and zlib compression.
These can be used to compress the message bodies and convert the string
encoding transparently.

-  `GLib.CharsetConverter`_
-  `GLib.ZLibCompressor`_
-  `GLib.ZLibDecompressor`_

.. _GLib.CharsetConverter: http://valadoc.org/#!api=gio-2.0/GLib.CharsetConverter
.. _GLib.ZlibCompressor: http://valadoc.org/#!api=gio-2.0/GLib.ZlibCompressor
.. _GLib.ZlibDecompressor: http://valadoc.org/#!api=gio-2.0/GLib.ZlibDecompressor

A typical utilisation would be to negociate a ``Content-Encoding: zlib`` header.

.. code-block:: vala

    app.get ((req, res) => {
        res.headers.replace ("Content-Encoding", "gzip");

        // the body will be compressed transparently
        res.body = new ConverterOutputStream (res.body, new ZLibCompressor ());

        res.body.write ("Hello world!".data);
    });

ChunkedConverter
----------------

The ``ChunkedConverter`` will convert written data into chunks according to
`RFC2126 section 3.6.1`_. It is used automatically if the ``Transport-Encoding``
header is set to ``chunked`` in the :doc:`response`.

.. _RFC2126 section 3.6.1: http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.6.1

