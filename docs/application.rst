Application
===========

This document explains step-by-step the sample presented in the
:doc:`getting-started` document.

Many implementations are provided and documented in :doc:`vsgi/server/index`.

Creating an application
-----------------------

An application is defined by a function that respects the ``VSGI.ApplicationCallback``
delegate. The :doc:`router` provides ``handle`` for that purpose along with
powerful routing facilities for client requests.

::

    var app = new Router ();

Binding a route
---------------

An application constitute of a list of routes matching and handling user
requests. The router provides helpers to declare routes which internally use
``Route`` instances.

::

    app.get ("/", (req, res, next, context) => {
        return res.expand_utf8 ("Hello world!", null);
    });

Every route declaration has a callback associated that does the request
processing. The callback, named handler, receives four arguments:

-  a :doc:`vsgi/request` that describes a resource being requested
-  a :doc:`vsgi/response` that correspond to that resource
-  a ``next`` continuation to `keep routing`
-  a routing ``context`` to retrieve and store states from previous and for
   following handlers

.. note ::

    For an alternative, more structured approach to route binding, see
    :ref:`cleaning-up-route-logic`

Serving the application
-----------------------

This part is pretty straightforward: you create a server that will serve
your application at port ``3003`` and since ``http`` was specified, it
will be served with :doc:`vsgi/server/http`.

::

    Server.new_with_application ("http", app.handle).run ({"app", "--port", "3003"});

:doc:`vsgi/server/index` takes a server implementation and an
``ApplicationCallback``, which is respected by the ``handle`` function.

Minimal application can be defined using a simple lambda function taking
a :doc:`vsgi/request` and :doc:`vsgi/response`.

::

    Server.new_with_application ("http", (req, res) => {
        res.status = 200;
        return res.expand ("Hello world!", null);
    }).run ({"app", "--port", "3003"});

Usually, you would only pass the CLI arguments to ``run``, so that your runtime
can be parametrized easily, but in this case we just want our application to
run with fixed parameters. Options are documented per implementation.

::

    public static void main (string[] args) {
        var app = new Router ();

        // assume some route declarations...

        Server.new_with_application ("http", app.handle).run (args);
    }

