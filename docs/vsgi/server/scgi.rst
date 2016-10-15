SCGI
====

SCGI (Simple Common Gateway Interface) is a stream-based protocol that is
particularly simple to implement.

.. note::

    SCGI is the recommended implementation and should be used when available as
    it takes the best out of GIO asynchronous API.

The implementation uses a :valadoc:`gio-2.0/GLib.SocketService` and processes
multiple requests using non-blocking I/O.

Parameters
----------

The only available parameter is ``backlog`` which set the depth of the listen
queue when performing the ``accept`` system call.

::

    var scgi_server = Server.new ("scgi", backlog: 1024);

