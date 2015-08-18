CGI
===

CGI is a very simple process-based protocol that uses commonly available
operations:

-   environment variables
-   standard input stream for the :doc:`../request`
-   standard output stream for the :doc:`../response`

The ``VSGI.CGI`` implementation provides a basis for CGI-like protocols such as
:doc:`fastcgi` and SCGI and can be used along with any HTTP server.

Since a process is spawned per request and exits when the latter finishes,
scheduled asynchronous tasks might not be processed. To overcome this issue,
``hold`` and ``release`` should be used to keep the server alive as long as
necessary.

If your task involve the :doc:`../request` or :doc:`../response` in its
callback, the connection will be kept alive until both are freed.

.. code:: vala

    using VSGI.CGI;

    new Server ("org.vsgi.CGI", (req, res) => {
        var source = new IdleSource ();

        source.set_callback (() => {
            message ("Hello world!");
            server.release ();
        });

        source.attach (MainContext.default ());

        server.hold ();
    });

lighttpd
--------

There is an example in ``examples/cgi`` providing a sample `lighttpd`_
configuration file. Once launched, the application can be accessed at the
following address: http://127.0.0.1:3003/cgi-bin/app/.

.. _lighttpd: http://www.lighttpd.net/

.. code-block:: bash

    lighttpd -D -f examples/cgi/lighttpd.conf

