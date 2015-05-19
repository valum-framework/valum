Application
===========

This document explains step-by-step the sample presented in
:doc:`getting-started`.

Choosing the VSGI implementation
--------------------------------

VSGI (Vala Server Gateway Interface) offers abstractions for different web
server technologies. You can choose which implementation you want with
a ``using`` statement, as they all respect a common interface.

Two implementations exist at the moment and a few more are planned in the next
minor release.

-  :doc:`server/soup`
-  :doc:`server/fastcgi`

.. code:: vala

    using Valum;
    using VSGI.Soup;

Creating an application
-----------------------

An application is defined by a class that implements the ``VSGI.Application``
interface. It declares a simple ``handle`` async function that takes
a :doc:`vsgi/request` and :doc:`vsgi/response` as input and process them.

Valum provides a :doc:`router`, which provides powerful facilities for routing
client requests. Your application is therefore an instance of that class.

.. code:: vala

    var app = new Router ();

Binding a route
---------------

An application constitute of a list of routes matching user requests. To
declare a route, the ``Router`` class provides useful helpers and low-level
utilities.

.. code:: vala

    app.get ("", (req, res) => {
        res.write ("Hello world!".data);
    });

Every route declaration has a callback associated that does the request
processing. The callback receives two arguments:

-  a :doc:`vsgi/request` that describes a resource being requested
-  a :doc:`vsgi/response` that correspond to that resource

These two inherit respectively from ``InputStream`` and ``OutputStream``,
allowing any synchronous and asynchronous stream operations. You can use
`GLib.DataOutputStream`_ or any wrapper from the GIO stream API to perform
advanced write operations.

.. _GLib.DataOutputStream: http://valadoc.org/#!api=gio-2.0/GLib.DataOutputStream

Serving the application
-----------------------

This part is pretty straightforward: you create a server that will serve your
application at port ``3003``. This will use the libsoup built-in HTTP server.

Usually, you would only pass the CLI arguments to ``run``, so that your runtime
can be parametrized easily.

.. code:: vala

    new Server (app).run ({"app", "--port", "3003"});

There is also a :doc:`server/fastcgi` implementation for a live deployment,
although you can still deploy with libsoup if you decide to use a modern
hosting service like `Heroku`_.

.. _Heroku: https://heroku.com

