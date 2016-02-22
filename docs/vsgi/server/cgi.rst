CGI
===

CGI is a very simple process-based protocol that uses commonly available
process resources:

-   environment variables
-   standard input stream for the :doc:`../request`
-   standard output stream for the :doc:`../response`

.. warning::

    The CGI protocol expects the response to be written in the standard output:
    writting there will most surely corrupt the response.

The ``VSGI.CGI`` implementation provides a basis for its derivatives protocols
such as :doc:`fastcgi` and :doc:`scgi` and can be used along with any HTTP
server.

The interpretation of the environment prioritize the `CGI/1.1`_ specification
while providing fallbacks with values we typically found like ``REQUEST_URI``.

.. _CGI/1.1: http://tools.ietf.org/html/draft-robinson-www-interface-00

Since a process is spawned per request and exits when the latter finishes,
scheduled asynchronous tasks might not be processed. To overcome this issue,
``hold`` and ``release`` should be used to keep the server alive as long as
necessary.

If your task involve the :doc:`../request` or :doc:`../response` in its
callback, the connection will be kept alive until both are freed.

.. code:: vala

    using VSGI.CGI;

    Server? server = null;

    ApplicationCallback app = (req, res) => {
        Idle.add (() => {
            message ("Hello world!");
            server.release ();
        });
        server.hold ();

        // no need to hold & release here, the reference on the request ensures
        // it already
        Idle.add (() => {
            req.body.write_all ("Hello world!".data, null);
        });

        return true;
    };

    server = new Server ("org.vsgi.CGI", app);

    server.run ();

lighttpd
--------

There is an example in ``examples/cgi`` providing a sample `lighttpd`_
configuration file. Once launched, the application can be accessed at the
following address: http://127.0.0.1:3003/cgi-bin/app/.

.. _lighttpd: http://www.lighttpd.net/

.. code-block:: bash

    lighttpd -D -f examples/cgi/lighttpd.conf

