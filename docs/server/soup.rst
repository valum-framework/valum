libsoup built-in server
=======================

libsoup provides a built-in HTTP server that you can use to test your
application or spawn workers in production.

.. code:: vala

    using VSGI.Soup;

    var app = new Router ();

    new Server (app).run ({"app", "--port", "3003"});
