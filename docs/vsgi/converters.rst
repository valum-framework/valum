Converters
==========

VSGI provide stream utilities named converters to convert data according to
modern web standards.

These are particularly useful to encode and recode request and response bodies
in VSGI implementations.

GLib provide default converters for charset conversion and zlib compression.
These can be used to compress the message bodies and convert the string
encoding transparently.

-  `GLib.CharsetConverter`_
-  `GLib.ZLibCompressor`_
-  `GLib.ZLibDecompressor`_

.. _GLib.CharsetConverter: http://valadoc.org/#!api=gio-2.0/GLib.CharsetConverter
.. _GLib.ZlibCompressor: http://valadoc.org/#!api=gio-2.0/GLib.ZlibCompressor
.. _GLib.ZlibDecompressor: http://valadoc.org/#!api=gio-2.0/GLib.ZlibDecompressor

Converters can be applied on both the :doc:`request` and :doc:`response` object
using the ``convert`` method.

.. warning::

    If the conversion affects the payload size, the ``Content-Length`` header
    must be modified appropriately. If the new size is indeterminate, set the
    encoding to `Soup.Encoding.EOF`_.

    Similarly, the ``Content-Encoding`` header must be adapted to reflect the
    current set of encodings applied (or unapplied) on the payload.

.. _Soup.Encoding.EOF: http://valadoc.org/#!api=libsoup-2.4/Soup.Encoding.EOF

One typical use case would be to apply a ``Content-Encoding: gzip`` header.

::

    new Server ("org.vsgi.App", (req, res) => {
        res.headers.append ("Content-Encoding", "gzip");
        res.convert (new ZlibCompressor (ZlibCompressorFormat.GZIP));
        return res.expand_utf8 ("Hello world!");
    });

Chunked encoder
---------------

The ``ChunkedEncoder`` will convert written data into chunks according to
`RFC2126 section 3.6.1`_.

.. _RFC2126 section 3.6.1: http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.6.1

