Bump
====

`Bump`_ is a library providing high-level concurrency patterns.

.. _Bump:

Resource pooling
----------------

A resource pool is a structure that maintain and dispatch a set of shared
resources.

There's various way of using the pool:

-   execute with a callback
-   acquire a claim that will release the resource automatically
-   acquire a resource that has to be released explicitly

::

    using Bump;
    using Valum;

    var app = new Router ();

    var connection_pool = new ResourcePool<Gda.Connection> ();

    connection_pool.construct_properties = {
        Property () {}
    };

    app.get ("/users", (req, res, next) => {
        return connection_pool.execute_async<bool> ((db) => {
            var users = db.execute_select_command ("select * from users");
            return next ();
        });
    });
