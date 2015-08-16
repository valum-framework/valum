Application
===========

This document explains step-by-step the sample presented in the
:doc:`getting-started` document.

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

-  :doc:`vsgi/server/soup`
-  :doc:`vsgi/server/fastcgi`

Creating an application
-----------------------

An application is defined by a function that respects the ``VSGI.ApplicationCallback``
delegate. The :doc:`router` provides ``handle`` for that purpose along with
powerful routing facilities for client requests.

.. code:: vala

    var app = new Router ();

Binding a route
---------------

An application constitute of a list of routes matching and handling user
requests. The router provides helpers to declare routes which internally use
a :doc:`route` instance.

.. code:: vala

    app.get ("", (req, res, next) => {
        res.body.write_all ("Hello world!".data, null);
    });

Every route declaration has a callback associated that does the request
processing. The callback, named handler, receives three arguments:

-  a :doc:`vsgi/request` that describes a resource being requested
-  a :doc:`vsgi/response` that correspond to that resource
-  a ``next`` continuation to `keep routing`

Serving the application
-----------------------

This part is pretty straightforward: you create a server that will serve your
application at port ``3003`` and since ``using VSGI.Soup`` was specified,
``Server`` refers to :doc:`vsgi/server/soup`.

.. code:: vala

    new Server (app.handle).run ({"app", "--port", "3003"});

:doc:`vsgi/server/index` take an ``ApplicationCallback`` as input, which is
respected by the ``handle`` function.  Simple application can be defined by
a simple lambda function taking a :doc:`vsgi/request` and :doc:`vsgi/response`
as input.

.. code:: vala

    new Server ((req, res) => {
        res.body.write ("Hello world!".data);
    }).run ({"app", "--port", "3003"});

Usually, you would only pass the CLI arguments to ``run``, so that your runtime
can be parametrized easily, but in this case we just want our application to
run with fixed parameters. Common options are documented in the
:doc:`vsgi/server/index` document.

.. code:: vala

    public static void main (string[] args) {
        var app = new Router ();

        // assume some route declarations...

        new Server (app.handle).run (args);
    }

