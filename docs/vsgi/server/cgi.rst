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

The ``VSGI.CGI`` namespace provides a basis for its derivatives protocols such
as :doc:`fastcgi` and :doc:`scgi` and can be used along with any HTTP server.

The interpretation of the environment prioritize the `CGI/1.1`_ specification
while providing fallbacks with values we typically found like ``REQUEST_URI``.

.. _CGI/1.1: http://tools.ietf.org/html/draft-robinson-www-interface-00

Since a process is spawned per request and exits when the latter finishes,
scheduled asynchronous tasks will not be processed.

If your task involve the :doc:`../request` or :doc:`../response` in its
callback, the connection and thus the process will be kept alive as long as
necessary.

::

    public class App : Handler {

        public override bool handle (Request req, Response res) {
            Timeout.add (5000, () => {
                res.expand_utf8 ("Hello world!");
                return Source.REMOVE;
            });
            return true;
        }
    }

    Server.new ("cgi", handler: new App ()).run ();

lighttpd
--------

There is an example in ``examples/cgi`` providing a sample `lighttpd`_
configuration file. Once launched, the application can be accessed at the
following address: http://127.0.0.1:3003/cgi-bin/app/.

.. _lighttpd: http://www.lighttpd.net/

.. code-block:: bash

    lighttpd -D -f examples/cgi/lighttpd.conf

