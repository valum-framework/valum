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

Lighttpd
--------

`Lighttpd`_ can be used to develop and potentially deploy your application.
More details about the FastCGI module are provided `in their wiki`_.

.. _Lighttpd: http://www.lighttpd.net/
.. _in their wiki: http://redmine.lighttpd.net/projects/lighttpd/wiki/Docs_ModFastCGI

.. literalinclude:: ../../../examples/fastcgi/lighttpd.conf
    :language: lighttpd

You can run the FastCGI example with Lighttpd:

.. code-block:: bash

    ./waf configure build --enable-examples
    lighttpd -D -f examples/fastcgi/lighttpd.conf

Apache
------

Under Apache, there are two mods available: ``mod_fcgid`` is more likely to be
available as it is part of Apache and ``mod_fastcgi`` is developed by those who
did the FastCGI specifications.

-  `mod\_fcgid <http://httpd.apache.org/mod_fcgid/>`__
-  `mod\_fastcgi <http://www.fastcgi.com/mod_fastcgi/docs/mod_fastcgi.html>`__

.. code-block:: apache

    <Location />
        FcgidWrapper /usr/libexec/app
    </Location>

Apache 2.5 provide a `mod_proxy_fcgi`_, which can serve FastCGI instance like
it currently does for :doc:`scgi` using the ``ProxyPass`` directive.

.. _mod_proxy_fcgi: https://httpd.apache.org/docs/trunk/mod/mod_proxy_fcgi.html

.. code-block:: apache

    ProxyPass fcgi://localhost:3003

Nginx
-----

Nginx expects a process to be already spawned and will communicate with it on
a TCP port or a UNIX socket path. Read more about `ngx_http_fastcgi_module`_.

.. _ngx_http_fastcgi_module: http://nginx.org/en/docs/http/ngx_http_fastcgi_module.html

.. code-block:: nginx

    location / {
        fastcgi_pass 127.0.0.1:3003;
    }

If possible, it's preferable to spawn processes locally and serve them through
a UNIX sockets. It is safer and much more efficient considering that requests
are not going through the whole network stack.

.. code-block:: nginx

    location / {
        fastcgi_pass unix:/var/run/app.sock;
    }

To spawn and manage a process, it is recommended to use a systemd unit and
socket. More details are available in `Lighttpd wiki`_. Otherwise, it's
possible to use the `spawn-fcgi`_ tool.

.. _Lighttpd wiki: https://redmine.lighttpd.net/projects/spawn-fcgi/wiki/Systemd
.. _spawn-fcgi: https://redmine.lighttpd.net/projects/spawn-fcgi/wiki

