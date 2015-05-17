FastCGI
=======

A FastCGI application is a simple process that communicate with a HTTP server
through unix or TCP a socket according to a specification.

VSGI use `Vala fcgi bindings`_ to provide a compliant FastCGI implementation.
See :doc:`../installation` for more information about the framework
dependencies.

.. _Vala fcgi bindings: http://www.masella.name/~andre/vapis/fcgi/index.htm

`lighttpd`_ can be used to develop and potentially deploy your application. An
`example of configuration`_ file is available in the fastcgi example folder.

.. _lighttpd: http://www.lighttpd.net/
.. _example of configuration: https://github.com/valum-framework/valum/tree/master/examples/fastcgi/lighttpd.conf

You can run the FastCGI example with lighttpd:

.. code-block:: bash

    ./waf configure
    ./waf build
    sudo ./waf install

    export LD_LIBRARY_PATH=/usr/local/lib64

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
