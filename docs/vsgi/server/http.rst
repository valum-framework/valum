HTTP
====

libsoup-2.4 provides a `built-in HTTP server`_ that you can use to test your
application or spawn workers in production.

.. _built-in HTTP server: http://valadoc.org/#!api=libsoup-2.4/Soup.Server

::

    using Valum;

    Server.new_with_application ("http", (req, res) => {
        return res.expand_utf8 ("Hello world!");
    }).run ({"app", "--port", "3003"});

Parameters
----------

The implementation provides most parameters provided by `Soup.Server`_.

.. _Soup.Server: http://valadoc.org/#!api=libsoup-2.4/Soup.Server

+-----------------------+-----------+-----------------------------------------+
| Parameter             | Default   | Description                             |
+=======================+===========+=========================================+
| ``interface``         | 3003      | listening interface if using libsoup's  |
|                       |           | old server API (<2.48)                  |
+-----------------------+-----------+-----------------------------------------+
| ``https``             | disabled  | listen for https connections rather     |
|                       |           | than plain http                         |
+-----------------------+-----------+-----------------------------------------+
| ``tls-certificate``   | none      | path to a file containing a PEM-encoded |
|                       |           | certificate                             |
+-----------------------+-----------+-----------------------------------------+
| ``server-header``     | disabled  | value to use for the "Server" header on |
|                       |           | Messages processed by this server.      |
+-----------------------+-----------+-----------------------------------------+
| ``raw-paths``         | disabled  | percent-encoding in the Request-URI     |
|                       |           | path will not be automatically decoded  |
+-----------------------+-----------+-----------------------------------------+

Notes
~~~~~

-  if ``--https`` is specified, you must provide a TLS certificate along
   with a private key

