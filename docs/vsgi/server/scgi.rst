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

Lighttpd
--------

Similarly to :doc:`fastcgi`, Lighttpd can be used to spawn and serve SCGI
processes.

.. literalinclude:: ../../../examples/scgi/lighttpd.conf
    :language: lighttpd

Apache
------

Apache can serve SCGI instances with `mod_proxy_scgi`_.

.. _mod_proxy_scgi: https://httpd.apache.org/docs/2.4/mod/mod_proxy_scgi.html

.. code-block:: apache

    ProxyPass / scgi://[::]:3003

Nginx
-----

Nginx support the SCGI protocol with `ngx_http_scgi_module`_ and can only pass
requests over TCP/IP and UNIX domain sockets.

.. code-block:: nginx

    location / {
        scgi_pass [::]:3003;
    }

.. _ngx_http_scgi_module: http://nginx.org/en/docs/http/ngx_http_scgi_module.html<Paste>
