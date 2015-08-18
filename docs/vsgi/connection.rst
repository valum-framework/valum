Connection
==========

All resources necessary to process a :doc:`request` and produce
a :doc:`response` are bound to the lifecycle of a connection instance.

.. warning::

    It is not recommended to use this directly as it will most likely result in
    corrupted operations with no regard to the transfer encoding or message
    format.

The connection can be accessed from the :doc:`request` ``connection`` property.
It is a simple `GLib.IOStream`_ that provides native access to the input and
output stream of the used technology.

.. _GLib.IOStream: http://valadoc.org/#!api=gio-2.0/GLib.IOStream

The following example shows how to bypass processing with higher-level
abstractions. It will only work on :doc:`server/soup`, as CGI-like protocols
require the status to be part of the response headers.

.. code::

    using VSGI.Soup;

    new Server ("org.vsgi.App", (req, res) => {
        var message = req.connection.output_stream;
        message.write_all ("200 Success HTTP/1.1\r\n".data. null);
        message.write_all ("Connection: close\r\n");
        message.write_all ("Content-Type: text/plain\r\n");
        message.write_all ("\r\n".data);
        message.write_all ("Hello world!".data);
    });

