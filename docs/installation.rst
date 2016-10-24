Installation
============

This document describes the compilation and installation process. Most of that
work is automated with `Meson`_, a build tool written in Python.

.. _Meson: http://mesonbuild.com/

Packages
--------

Packages for RPM and Debian based Linux distributions will be provided for
stable releases so that the framework can easily be installed in a container or
production environment.

Fedora
~~~~~~

RPM packages for Fedora (22, 23, 24 and rawhide) are available from the
`arteymix/valum-framework`_ Copr repository.

.. _arteymix/valum-framework: https://copr.fedoraproject.org/coprs/arteymix/valum-framework/

.. code-block:: bash

    dnf copr enable arteymix/valum-framework

The `valum` package contains the shared library and `valum-devel` contains all
that is necessary to build an application.

.. code-block:: bash

    dnf install valum valum-devel

Nix
~~~

.. code-block:: bash

    nix-shell -p valum

Subproject
----------

If your project uses the Meson build system, you may integrate the framework as
a subproject. The project must be cloned in the ``subprojects`` folder,
preferably using a git submodule. Be careful using a tag and not the ``master``
trunk.

The following variables can be used as dependencies:

-   ``vsgi`` for the abstraction layer
-   ``valum`` for the framework

Note that due to Meson design, dependencies must be explicitly provided.

.. code-block:: python

    project('app', 'c', 'vala')

    glib = dependency('glib-2.0')
    gobject = dependency('gobject-2.0')
    gio = dependency('gio-2.0')
    soup = dependency('libsoup-2.4')
    vsgi = subproject('valum').get_variable('vsgi')
    valum = subproject('valum').get_variable('valum')

    executable('app', 'app.vala',
               dependencies: [glib, gobject, gio, soup, vsgi, valum])

Dependencies
------------

The following dependencies are minimal to build the framework under Ubuntu
12.04 LTS and should be satisfied by most recent Linux distributions.

+--------------+----------+
| Package      | Version  |
+==============+==========+
| vala         | >=0.26   |
+--------------+----------+
| python       | >=3.4    |
+--------------+----------+
| meson        | >=0.36   |
+--------------+----------+
| ninja        | >=1.6.0  |
+--------------+----------+
| glib-2.0     | >=2.40   |
+--------------+----------+
| gio-2.0      | >=2.40   |
+--------------+----------+
| gio-unix-2.0 | >=2.40   |
+--------------+----------+
| libsoup-2.4  | >=2.44   |
+--------------+----------+

Recent dependencies will enable more advanced features:

+-------------+---------+------------------------------------------------------+
| Package     | Version | Feature                                              |
+=============+=========+======================================================+
| gio-2.0     | >=2.44  | better support for asynchronous I/O                  |
+-------------+---------+------------------------------------------------------+
| libsoup-2.4 | >=2.48  | new server API                                       |
+-------------+---------+------------------------------------------------------+

You can also install additional dependencies to build the examples, you will
have to specify the ``-D enable_examples=true`` flag during the configure step.

+---------------+------------------------------------+
| Package       | Description                        |
+===============+====================================+
| ctpl          | C templating library               |
+---------------+------------------------------------+
| gee-0.8       | data structures                    |
+---------------+------------------------------------+
| json-glib-1.0 | JSON library                       |
+---------------+------------------------------------+
| libmemcached  | client for memcached cache storage |
+---------------+------------------------------------+
| libluajit     | embed a Lua VM                     |
+---------------+------------------------------------+
| libmarkdown   | parser and generator for Markdown  |
+---------------+------------------------------------+
| template-glib | templating library                 |
+---------------+------------------------------------+

Download the sources
--------------------

You may either clone the whole git repository or download one of our
`releases from GitHub`_:

.. _releases from GitHub: https://github.com/valum-framework/valum/releases

.. code-block:: bash

    git clone git://github.com/valum-framework/valum.git && cd valum

The ``master`` branch is a development trunk and is not guaranteed to be very
stable. It is always a better idea to checkout the latest tagged release.

Build
-----

.. code-block:: bash

    mkdir build && cd build
    meson ..
    ninja # or 'ninja-build' on some distribution

Install
-------

The framework can be installed for system-wide availability.

.. code-block:: bash

    sudo ninja install

Once installed, VSGI implementations will be looked up into ``${prefix}/${libdir}/vsgi-0.3/servers``.
This path can be changed by setting the ``VSGI_SERVER_PATH`` environment
variable.

Run the tests
--------------

.. code-block:: bash

    ninja test

If any of them fail, please `open an issue on GitHub`_ so that we can tackle
the bug. Include the test logs (e.g. ``build/meson-private/mesonlogs.txt``) and
any relevant details.

.. _open an issue on GitHub: https://github.com/valum-framework/valum/issues

Run the sample application
--------------------------

You can run the sample application from the ``build`` folder if you called
``meson`` with the ``-D enable_examples=true`` flag. The following example uses
the :doc:`vsgi/server/http` server.

.. code-block:: bash

    ./build/example/app/app
