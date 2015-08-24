Filters
=======

Filters are compositions of :doc:`request` or :doc:`response` that provide
various features such as buffering, caching and compression. They are based on
the ``FilteredRequest`` and ``FilteredResponse`` abstract classes.

They are the natural extension to `GLib.FilterInputStream`_ and
`GLib.FilterOutputStream`_, but adapted for VSGI.

Two basic filters are provided to apply a `GLib.Converter`_ on the body stream
that is either incoming or outgoing with ``ConvertedResponse`` and
``ConvertedRequest`` respectively.

The following example uses a converter to seamlessly compress the response body
You can use any :doc:`converters` provided by GLib or VSGI with ease.

.. _GLib.Converter: http://valadoc.org/#!api=gio-2.0/GLib.Converter
.. _GLib.FilterInputStream: http://valadoc.org/#!api=gio-2.0/GLib.FilterInputStream
.. _GLib.FilterOutputStream: http://valadoc.org/#!api=gio-2.0/GLib.FilterOutputStream

.. code:: vala

    using VSGI;

    new Server ("org.vsgi.App", (req, res) => {
        res = new ConvertedResponse (res, new ZlibCompressor (ZlibCompressorFormat.GZIP));
        res.status = 200;
        res.headers.append ("Content-Encoding", "gzip");
        res.body.write_all ("Hello world!".data);
    });

