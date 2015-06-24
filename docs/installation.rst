Installation
============

We use the `waf build system`_ and distribute it with the sources. All you need
is a `Python interpreter`_ to configure and build Valum.

.. _waf build system: https://code.google.com/p/waf/
.. _Python interpreter: https://www.python.org/

Dependencies
------------

The following dependencies are minimal to build the framework under Ubuntu
12.04 LTS:

+-------------+----------+
| Package     | Version  |
+=============+==========+
| vala        | latest   |
+-------------+----------+
| waf         | provided |
+-------------+----------+
| glib-2.0    | >=2.32   |
+-------------+----------+
| gio-2.0     | >=2.32   |
+-------------+----------+
| libsoup-2.4 | >=2.38   |
+-------------+----------+
| libgee-0.8  | >=0.6.4  |
+-------------+----------+
| ctpl        | >=3.3    |
+-------------+----------+

Recent dependencies will enable more advanced features:

+-------------+---------+------------------------------------------------------+
| Package     | Version | Feature                                              |
+=============+=========+======================================================+
| glib-2.0    | >=2.38  | subprocess in tests                                  |
+-------------+---------+------------------------------------------------------+
| gio-2.0     | >=2.40  | CLI arguments parsing                                |
+-------------+---------+------------------------------------------------------+
| gthread-2.0 | any     | threading for VSGI implementations                   |
+-------------+---------+------------------------------------------------------+
| libsoup-2.4 | >=2.48  | new server API                                       |
+-------------+---------+------------------------------------------------------+
| libsoup-2.4 | >=2.50  | uses `Soup.ClientContext.steal_connection`_ directly |
+-------------+---------+------------------------------------------------------+

Threading can be enabled by specifying the ``--enable-threading`` flag during
the configuration.

You can also install additional dependencies to build the examples:

-  libmemcached
-  libluajit
-  memcached

.. _Soup.ClientContext.steal_connection: http://valadoc.org/#!api=libsoup-2.4/Soup.ClientContext.steal_connection

Debian and Ubuntu
~~~~~~~~~~~~~~~~~

.. code-block:: bash

    apt-get install git-core build-essential python valac libglib2.0-bin \
                    libglib2.0-dev libsoup2.4-dev libgee-0.8-dev libfcgi-dev \
                    memcached libmemcached-dev libluajit-5.1-dev libctpl-dev

Fedora
~~~~~~

.. code-block:: bash

    yum install git python vala glib2-devel libsoup-devel libgee-devel fcgi-devel \
                memcached libmemcached-devel luajit-devel ctpl-devel

Download the sources
--------------------

You may either clone or download one of our `releases`_ from GitHub:

.. _releases: https://github.com/antono/valum/releases

.. code-block:: bash

    git clone git://github.com/valum-framework/valum.git && cd valum

Build
-----

Build Valum and run the tests to make sure everything is fine.

.. code-block:: bash

    ./waf configure
    ./waf build && ./build/tests/tests
    sudo ./waf install

Export LD_LIBRARY_PATH
----------------------

By default, installation is prefixed by ``/usr/local``, which is generally not
in the dynamic library path. You have to export ``LD_LIBRARY_PATH`` for it to
work.

.. code-block:: bash

    export LD_LIBRARY_PATH=/usr/local/lib64 # just lib on 32-bit systems

Run the sample application
--------------------------

You can run the sample application from the ``build`` folder, it uses
the `libsoup built-in HTTP server`_ and should run out of the box.

.. _libsoup built-in HTTP server: https://developer.gnome.org/libsoup/stable/libsoup-server-howto.html

.. code-block:: bash

    ./build/example/app/app
