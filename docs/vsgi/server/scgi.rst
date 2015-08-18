SCGI
====

SCGI (Simple Common Gateway Interface) is a stream-based protocol that is
particularly simple to implement.

.. note::

    SCGI is the recommended implementation and should be used when available as
    it takes the best out of GIO asynchronous API.

The implementation uses a `GLib.ThreadedSocketService`_ to process multiple
requests concurrently. It is critical to either avoid shared states or use
`GLib.Mutex`_ or ``lock`` properly.

.. _GLib.ThreadedSocketService: http://valadoc.org/#!api=gio-2.0/GLib.ThreadedSocketService
.. _GLib.Mutex: http://valadoc.org/#!api=glib-2.0/GLib.Mutex

.. code:: vala

    using VSGI.SCGI;

    var shared_state = 5;

    new Server ("org.vsgi.SCGI", (req, res) => {
        // ...
        lock (shared_state) {
            shared_state++;
        }
    }).run ();

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

