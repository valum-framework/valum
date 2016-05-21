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

::

    new Server ("org.vsgi.App", (req, res) => {
        res.headers.append ("Content-Encoding", "gzip");
        res.convert (new ZlibCompressor (ZlibCompressorFormat.GZIP));
        return res.expand_utf8 ("Hello world!");
    });

.. warning::

    The ``Content-Encoding`` header must be adapted to reflect the current set
    of encodings applied (or unapplied) on the payload.

Since conversion typically affect the resulting size of the payload, the
``Content-Length`` header must be set appropriately. To ease that, the new
value can be specified as second argument. Note that ``0`` and ``-1`` are
respectively used to describe a complete sink and an undetermined length.

::

    res.convert (new CharsetConverter ("UTF-8", "ascii"), res.headers.get_content_length ());

The default, which apply in most cases, is to remove the ``Content-Length``
header and thus describe an undetermined length.

Chunked encoder
---------------

The ``ChunkedEncoder`` will convert written data into chunks according to
`RFC2126 section 3.6.1`_.

.. _RFC2126 section 3.6.1: http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.6.1

