Persistence
===========

Multiple persistence solutions have bindings in Vala and can be used by Valum.

-  `libgda`_ for relational databases and more
-  `memcached`_
-  `redis-glib`_
-  `mongodb-glib`_
-  `couchdb-glib`_ which is supported by the Ubuntu team

.. _libgda: https://developer.gnome.org/libgda/stable/
.. _memcached: http://memcached.org/
.. _redis-glib: https://github.com/chergert/redis-glib
.. _mongodb-glib: https://github.com/chergert/mongo-glib
.. _couchdb-glib: https://launchpad.net/couchdb-glib

One good general approach is to use a per-process connection pool since
handlers are executing in asynchronous context, your application will greatly
benefit from multiple connections.

Memcached
---------

You can use `libmemcached.vapi`_ to access a Memcached cache storage, it is
maintained in nemequ/vala-extra-vapis GitHub repository.

.. _libmemcached.vapi: https://github.com/nemequ/vala-extra-vapis/blob/master/libmemcached.vapi

.. code:: vala

    using Valum;
    using VSGI.Soup;

    var app       = new Router ();
    var memcached = new Memcached.Context ();

    app.get ("<key>", (req, res) => {
        var key = req.params["key"];

        int32 flags;
        Memcached.ReturnCode error;
        var value = memcached.get ("hello", out flags, out error);

        res.write (value);
    });

    app.post ("<key>", (req, res) => {
        var key    = req.params["key"];
        var buffer = new MemoryOutputStream.resizable ();

        // fill the buffer with the request body
        buffer.splice (req);

        int32 flags;
        Memcached.ReturnCode error;
        var value = memcached.get ("hello", out flags, out error);

        res.write (value);
    });
