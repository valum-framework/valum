VSGI
====

VSGI is a middleware that interfaces different Web server technologies under a
common and simple set of abstractions.

For the moment, it is developed along with Valum to target the needs of a Web
framework, but it will eventually be extracted and distributed as a shared
library.

.. toctree::

    authentication
    connection
    request
    response
    cookies
    converters
    server/index

VSGI produces process-based applications that are able to communicate with
various HTTP servers using standardized protocols.

Handler
-------

The entry point of any VSGI application implement the :valadoc:`vsgi-0.3/VSGI.Handler`
abstract class. It provides a function of two arguments: a :doc:`request` and
a :doc:`response` that return a boolean indicating if the request has been or
will be processed. It may also raise an error.

::

    using VSGI;

    public class App : Handler {

        public override handle (Request req, Response res) throws Error {
            // process the request and produce the response...
            return true;
        }
    }

    Server.new ("http", handler: new App ()).run ();

If a handler indicate that the request has not been processed, it's up to the
server implementation to decide what will happen.

From now on, examples will consist of :valadoc:`vsgi-0.3/VSGI.Handler.handle`
content to remain more concise.

Error handling
~~~~~~~~~~~~~~

.. versionadded:: 0.3

At any moment, an error can be raised and handled by the server implementation
which will in turn teardown the connection appropriately.

::

    throw new IOError.FAILED ("some I/O failed");

Asynchronous processing
~~~~~~~~~~~~~~~~~~~~~~~

The asynchronous processing model follows the `RAII pattern`_ and wraps all
resources in a connection that inherits from :valadoc:`gio-2.0/GLib.IOStream`.
It is therefore important that the said connection is kept alive as long as the
streams are being used.

.. _RAII pattern: https://en.wikipedia.org/wiki/Resource_Acquisition_Is_Initialization

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

::

    res.body.write_async.begin ("Hello world!",
                                Priority.DEFAULT,
                                null,
                                (body, result) => {
        // the response reference will make the connection persist
        var written = res.body.write_async.end (result);
    });

Dynamic loading
~~~~~~~~~~~~~~~

.. versionadded:: 0.3

It could be handy to dynamically load handlers the same way
:doc:`server/index` are.

Fortunately, this can be performed with the ``HandlerModule`` by providing
a directory and name for the shared library containing a dynamically loadable
application.

::

    var module = var new HandlerModule ("<directory>", "<name>");

    Server.new ("http", handler: Object.new (module.handler_type)).run ();

The only required definition is a ``handler_init`` symbol that return the type
of some ``Handler``. In this case, the library should be located in ``<directory>/lib<name>.so``,
although the actual name is system-dependant.

::

    [ModuleInit]
    public Type handler_init (TypeModule type_module) {
        return typeof (App);
    }

    public class App : Handler {

        public bool handle (Request req, Response res) {
            return res.expand_utf8 ("Hello world!");
        }
    }

Eventually, this will be used to provide a utility to run arbitrary
applications with support for live-reloading.

