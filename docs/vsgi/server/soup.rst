libsoup-2.4 built-in server
============================

libsoup-2.4 provides a `built-in HTTP server`_ that you can use to test your
application or spawn workers in production.

.. _built-in HTTP server: http://valadoc.org/#!api=libsoup-2.4/Soup.Server

.. code:: vala

    using Valum;
    using VSGI.Soup;

    var app = new Router ();

    new Server (app).run ({"app", "--port", "3003"});

Options
-------

The implementation provides most options provided by `Soup.Server`_ through
command-line options. The available options may vary and can be asserted with
the ``--help`` flag.

.. _Soup.Server: http://valadoc.org/#!api=libsoup-2.4/Soup.Server

+-----------------------+-----------+-----------------------------------------+
| Option                | Default   | Description                             |
+=======================+===========+=========================================+
| ``--port``            | 3003      | port the server is listening on         |
+-----------------------+-----------+-----------------------------------------+
| ``--all``             | local     | listen on all interfaces                |
+-----------------------+-----------+-----------------------------------------+
| ``--ipv4-only``       | disabled  | only listen to IPv4 interfaces          |
+-----------------------+-----------+-----------------------------------------+
| ``--ipv6-only``       | disabled  | only listen on IPv6 interfaces          |
+-----------------------+-----------+-----------------------------------------+
| ``--file-descriptor`` | none      | listen to the provided file descriptor  |
+-----------------------+-----------+-----------------------------------------+
| ``--https``           | disabled  | listen for https connections rather     |
|                       |           | than plain http                         |
+-----------------------+-----------+-----------------------------------------+
| ``--ssl-cert-file``   | none      | path to a file containing a PEM-encoded |
|                       |           | certificate                             |
+-----------------------+-----------+-----------------------------------------+
| ``--ssl-key-file``    | none      | path to a file containing a PEM-encoded |
|                       |           | private key                             |
+-----------------------+-----------+-----------------------------------------+
| ``--server-header``   | Valum/0.2 | value to use for the "Server" header on |
|                       |           | Messages processed by this server.      |
+-----------------------+-----------+-----------------------------------------+
| ``--raw-paths``       | disabled  | percent-encoding in the Request-URI     |
|                       |           | path will not be automatically decoded  |
+-----------------------+-----------+-----------------------------------------+

Notes
~~~~~

-  if ``--all`` is not supplied, the server will only listen to local
   interfaces
-  ``--all`` can be combined with ``--ipv4-only`` or ``--ipv4-only`` to listen
   on all IPv4 or IPv6 interfaces
-  if ``--https`` is specified, you must provide a SSL or TLS certificate along
   with a private key

