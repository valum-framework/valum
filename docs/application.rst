Application
===========

This section explains what is going on in a Valum web application using
a sample that can be found in the `Gettings
started <getting-started.md>`__ section of the documentation.

Choosing the VSGI implementation
--------------------------------

Choosing a VSGI implementation is just a matter of using the right
namespace. Two implementations are currently available for now:

-  libsoup built-in server
-  FastCGI

.. code:: vala

    using Valum;
    using VSGI.Soup;

Creating an application
-----------------------

An application is an instance of the ``Router`` class.

.. code:: vala

    var app = new Router ();

Binding a route
---------------

An application constitute of a list of routes matching user requests. To
declare a route, the ``Router`` class provides useful helpers and
low-level utilities.

.. code:: vala

    app.get("", (req, res) => {
        var writer = new DataOutputStream (res);
        writer.put_string ("Hello world!");
    });

Every route declaration has a callback associated that does the request
processing. The callback receives two arguments:

-  `Request <vsgi/request.md>`__ representing what is begin requested
-  `Response <vsgi/response.md>`__ representing what will be sent back
   to the requester

These two inherit respectively from ``InputStream`` and
``OutputStream``, allowing any synchronous and asynchronous stream
operations.

Serving the application
-----------------------

This part is pretty straightforward: you create a server that will serve
your application at port ``3003``. This will use the libsoup built-in
HTTP server.

.. code:: vala

    new Server (app, 3003).run ();

There is a `FastCGI implementation <server/fastcgi.md>`__ for a live
deployment.
