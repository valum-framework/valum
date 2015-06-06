Application
===========

This document explains step-by-step the sample presented in
:doc:`getting-started`.

Choosing the VSGI implementation
--------------------------------

VSGI (Vala Server Gateway Interface) offers abstractions for different web
server technologies. You can choose which implementation you want with
a ``using`` statement as they all respect a common interface.

.. code:: vala

    using Valum;
    using VSGI.Soup; // or VSGI.FastCGI

Two implementations exist at the moment and a few more are planned in a future
minor release.

-  :doc:`server/soup`
-  :doc:`server/fastcgi`

Creating an application
-----------------------

An application is defined by a class that implements the ``VSGI.Application``
interface. It declares a simple ``handle`` function that takes
a :doc:`vsgi/request` and :doc:`vsgi/response` as input and process them.

Valum provides a :doc:`router` with powerful facilities for routing client
requests. Your application is an instance of that class.

.. code:: vala

    var app = new Router ();

Binding a route
---------------

An application constitute of a list of routes matching and handling user
requests. The router provides helpers to declare routes which internally use
a :doc:`route` instance.

.. code:: vala

    app.get ("", (req, res, next) => {
        res.write ("Hello world!".data);
    });

Every route declaration has a callback associated that does the request
processing. The callback, named handler, receives three arguments:

-  a :doc:`vsgi/request` that describes a resource being requested
-  a :doc:`vsgi/response` that correspond to that resource
-  a ``next`` continuation to `keep routing`

:doc:`vsgi/request` and :doc:`vsgi/response` inherit respectively from
`GLib.InputStream`_ and `GLib.OutputStream`_, allowing any synchronous and
asynchronous stream operations. You can use `GLib.DataOutputStream`_ or any
filter from the GIO stream API to perform advanced write operations.

.. _GLib.InputStream: http://valadoc.org/#!api=gio-2.0/GLib.InputStream
.. _GLib.OutputStream: http://valadoc.org/#!api=gio-2.0/GLib.OutputStream
.. _GLib.DataOutputStream: http://valadoc.org/#!api=gio-2.0/GLib.DataOutputStream

Serving the application
-----------------------

The :doc:`server/soup` will be used to serve your application at port ``3003``.

Usually, you would only pass the CLI arguments to ``run``, so that your runtime
can be parametrized easily.

.. code:: vala

    new Server (app).run ({"app", "--port", "3003"});

There is also a :doc:`server/fastcgi` implementation for a deployment on pretty
much any existing HTTP server. However, you can still deploy with libsoup if
you decide to use a modern hosting service like `Heroku`_.

.. _Heroku: https://heroku.com

