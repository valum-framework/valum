libsoup built-in server
=======================

libsoup provides a `built-in HTTP server`_ that you can use to test your
application or spawn workers in production.

.. _built-in HTTP server: http://valadoc.org/#!api=libsoup-2.4/Soup.Server

.. code:: vala

    using Valum;
    using VSGI.Soup;

    var app = new Router ();

    new Server (app).run ({"app", "--port", "3003"});

