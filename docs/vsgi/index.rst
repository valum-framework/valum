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

        public override bool handle (Request req, Response res) throws Error {
            // process the request and produce the response...
            return true;
        }
    }

    Server.new ("http", handler: new App ()).run ();

If a handler indicate that the request has not been processed, it's up to the
server implementation to decide what will happen.

Asynchronous handling
~~~~~~~~~~~~~~~~~~~~~

.. versionadded:: 0.4

To go asynchronous, one can override the :valadoc:`vsgi-0.3/VSGI.Handler.handle_async`
symbol instead.

::

    using VSGI;

    public class App : Handler {

        public override async bool handle_async (Request req, Response res) throws Error {
            // process the request and produce the response...
            return true;
        }
    }

    Server.new ("http", handler: new App ()).run ();

From now on, examples will consist of :valadoc:`vsgi-0.3/VSGI.Handler.handle`
content to remain more concise.

Error handling
~~~~~~~~~~~~~~

.. versionadded:: 0.3

At any moment, an error can be raised and handled by the server implementation
which will in turn teardown the connection appropriately.

::

    throw new IOError.FAILED ("some I/O failed");

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

Loader
------

.. versionadded:: 0.4

VSGI provide the ``vsgi-loader`` utility designed to serve handlers written as
:valadoc:`gmodule-2.0/GLib.Module` from any supported implementation, no
recompilation needed.

Furthermore, it also provide a live-reloader based on :valadoc:`gio-2.0/GLib.FileMonitor`
to remove the necessity of restarting the server if the application code changes.

Usage
~~~~~

The ``vsgi-loader`` program can be used as follow:

.. code-block:: bash

    vsgi-loader [--directory=<directory>] [--server=<server>] [--live-reload] <module_name> -- <server_arguments>

-  the ``directory`` where the shared library is located or default system path
-  the ``server`` implementation which is either ``http``, ``fastcgi`` or
   ``scgi`` and defaults to ``http``
-  if ``--live-reload`` is set, the server will automatically reload the shared
   library on change
-  the name of the library without the ``lib`` prefix and ``.so`` extension
-  arguments for the server implementation specified by the ``--server`` flag
   and delimited by ``--``

.. warning::

    Arguments for the server implementation must be separated by a ``--``
    indicator, otherwise they will be interpreted by ``vsgi-loader``.

.. code-block:: bash

    vsgi-loader --directory=build/examples/loader loader -- --port=3005

Additional arguments are described in ``vsgi-loader --help``.

.. code-block:: bash

    vsgi-loader --help

For details about server-specific options, the ``--help`` flag can be passed
beyond.

.. code-block:: bash

    vsgi-loader --server=fastcgi app -- --help

Initialization
~~~~~~~~~~~~~~

To perform initialization, one can implement the :valadoc:`gio-2.0/GLib.Initable`
interface, it will automatically be called by the loader.

::

    [ModuleInit]
    public Type handler_init (TypeModule type_module) {
        return typeof (App);
    }

    public class App : Handler, Initable {

        public Gda.Connection database { get; construct; }

        public bool init (Cancellable? cancellable = null) throws Error {
            database.open ();
        }

        public bool handle (Request req, Response res) {
            return res.expand_utf8 ("Hello world!");
        }
    }
