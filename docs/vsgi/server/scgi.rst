SCGI
====

SCGI (Simple Common Gateway Interface) is a stream-based protocol that is
particularly simple to implement.

The implementation takes the best out of GIO asynchronous APIs as it is purely
implemented with it.

.. _GLib.SocketService:

.. code:: vala

    using VSGI.SCGI;

    app.get ("", (req, res) => {
        // ...
    });

    new Server (app.handle).run ();

Connections being handling in worker threads, it is critical to avoid shared
state or to use `GLib.Mutex`_ properly.

.. _GLib.Mutex: http://valadoc.org/#!api=glib-2.0/GLib.Mutex

Options
-------

+-----------------------+---------+-----------------------------------------------+
| Option                | Default | Description                                   |
+=======================+=========+===============================================+
| ``--port``            | none    | listen on a TCP port from local interface     |
+-----------------------+---------+-----------------------------------------------+
| ``--file-descriptor`` | 0       | listen to the provided file descriptor        |
+-----------------------+---------+-----------------------------------------------+
| ``--backlog``         | 0       | connection queue depth in the ``listen`` call |
+-----------------------+---------+-----------------------------------------------+
| ``--max-threads``     | -1      | the maximal number of threads to execute      |
|                       |         | concurrently handling incoming clients        |
+-----------------------+---------+-----------------------------------------------+

In the case of ``--max-threads``, ``-1`` means no limit.

