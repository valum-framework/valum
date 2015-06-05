CGI
===

CGI are very simple process-based protocol that uses commonly available
operations:

-   environment variables
-   standard input stream :doc:`../request`
-   standard output stream :doc:`../response`

The ``VSGI.CGI`` implementation provides a basis for CGI-like protocols such as
:doc:`fastcgi` and SCGI and can be used along with any HTTP server.

lighttpd
--------

The example in ``examples/cgi`` provides a sample lighttpd configuration file,
the server application can be accessed at http://127.0.0.1:3003/cgi-bin/app/
once the HTTP server is running.

.. code-block:: bash

    lighttpd -D -f examples/cgi/lighttpd.conf

