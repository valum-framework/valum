FastCGI
=======

FastCGI is a binary protocol that multiplexes requests over a single
connection.

VSGI uses :valadoc:`fcgi/FastCGI` under the hood to provide a compliant
implementation. See :doc:`../../installation` for more information about the
framework dependencies.

The whole request cycle is processed in a thread and dispatched in the main
context, so it's absolutely safe to use shared states.

By default, the FastCGI implementation listens on the file descriptor ``0``,
which is conventionally the case when the process is spawned by an HTTP server.

The implementation only support file descriptors, UNIX socket paths and IPv4
addresses on the loopback interface.

Parameters
----------

The only available parameter is ``backlog`` which set the depth of the listen
queue when performing the ``accept`` system call.

::

    var fastcgi_server = Server.new ("fastcgi", backlog: 1024);

lighttpd
--------

`lighttpd`_ can be used to develop and potentially deploy your application. An
`example of configuration`_ file is available in the fastcgi example folder.

.. _lighttpd: http://www.lighttpd.net/
.. _example of configuration: https://github.com/valum-framework/valum/tree/master/examples/fastcgi/lighttpd.conf

You can run the FastCGI example with lighttpd:

.. code-block:: bash

    ./waf configure --enable-examples && ./waf build
    lighttpd -D -f examples/fastcgi/lighttpd.conf

Apache
------

Under Apache, there are two mods available: ``mod_fcgid`` is more likely to be
available as it is part of Apache and ``mod_fastcgi`` is developed by those who
did the FastCGI specifications.

-  `mod\_fcgid <http://httpd.apache.org/mod_fcgid/>`__
-  `mod\_fastcgi <http://www.fastcgi.com/mod_fastcgi/docs/mod_fastcgi.html>`__

Nginx
-----

Nginx expect a process to be already spawned and will communicate with it using
a TCP port or a socket path. Read more about `ngx_http_fastcgi_module`_.

You can spawn a process with `spawn-fcgi`_, an utility part of lighttpd.

.. _ngx_http_fastcgi_module: http://nginx.org/en/docs/http/ngx_http_fastcgi_module.html
.. _spawn-fcgi: https://github.com/lighttpd/spawn-fcgi
