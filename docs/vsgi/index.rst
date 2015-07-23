VSGI
====

VSGI is a middleware that interfaces different web server technologies under a
common and simple set of abstractions.

For the moment, it is developed along with Valum to target the needs of a web
framework, but it will eventually be extracted and distributed as a shared
library.

It actually supports two technologies (libsoup-2.4 and FastCGI) and more
implementations are planned when the specification will be more stable.

.. toctree::

    request
    response
    converters
    server/index

VSGI produces process-based applications that are able to communicate with
various HTTP servers with protocols and process their client requests
asynchrously.

Entry point
-----------

The entry point of a VSGI application is type-compatible with the
`ApplicationCallback` delegate. It is a function of two arguments:
a :doc:`request` and a :doc:`response`.

.. code:: vala

    using VSGI.Soup;

    new Server ((req, res) => {
        // process the request and produce the response...
    }).run ();

Accessing the :doc:`response` ``body`` for the first time will write the status
line and headers synchronously in the connection stream before returning an
`GLib.OutputStream`_.

.. _GLib.OutputStream: http://valadoc.org/#!api=gio-2.0/GLib.OutputStream

.. warning::

    The :doc:`response` body must be accessed at least once during the
    processing to ensure that the headers will be written and filters applied.

Asynchronous processing
-----------------------

The asynchronous processing model follows the `RAII pattern`_ and wraps all
resources in a connection that inherits from `GLib.IOStream`_. It is therefore
important that the said connection is kept alive as long as the streams are
being used.

.. _RAII pattern: https://en.wikipedia.org/wiki/Resource_Acquisition_Is_Initialization
.. _GLib.IOStream: http://valadoc.org/#!api=gio-2.0/GLib.IOStream

The :doc:`request` holds a reference to the said connection and the
:doc:`response` indirectly does as it holds a reference to the request.
Generally speaking, holding a reference on any of these two instances is
sufficient to keep the streams usable.

.. warning::

    As VSGI relies on reference counting to free the resources underlying
    a request, you must keep a reference to either the :doc:`request` or
    :doc:`response` during the processing, including in asynchronous callbacks.

It is important that the connection persist until all streams operations are
done as the following example demonstrates:

.. code:: vala

    res.body.write_async.begin ("Hello world!",
                                Priority.DEFAULT,
                                null,
                                (body, result) => {
        // the response reference will make the connection persist
        var written = res.body.write_async.end (result);
    });

