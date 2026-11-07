Installation
============

This document describes the compilation and installation process. Most of that
work is automated with `Meson`_, a build tool written in Python.

.. _Meson: http://mesonbuild.com/

If your project uses the Meson build system, you may integrate the framework as
a subproject. The project must be cloned in the ``subprojects`` folder,
preferably using a git submodule. Be careful using a tag and not the ``master``
trunk.

The following variables can be used as dependencies:

-   ``vsgi_dep`` for the abstraction layer
-   ``valum_dep`` for the framework

Note that due to Meson design, dependencies must be explicitly provided.

.. code-block:: python

    project('app', 'c', 'vala')

    glib_dep = dependency('glib-2.0')
    gobject_dep = dependency('gobject-2.0')
    gio_dep = dependency('gio-2.0')
    soup_dep = dependency('libsoup-2.4')
    vsgi_dep = subproject('valum').get_variable('vsgi_dep')
    valum_dep = subproject('valum').get_variable('valum_dep')

    executable('app', 'app.vala',
               dependencies: [glib_dep, gobject_dep, gio_dep, soup_dep, vsgi_dep, valum_dep])

Alternatively, you can use the ``[wrap-git]`` feature instead of introducing
and tracking a git submodule. Simply add ``subprojects/valum.wrap`` in your
tree with the following content:

::

    [wrap-git]
    directory=valum
    url=https://github.com/valum-framework/valum.git
    revision=master

Then, invoking `meson` to configure the project will automatically clone the
repository and checkout the specified revision.

Dependencies
------------

The following dependencies are minimal to build the framework under Ubuntu
24.04 LTS and should be satisfied by most recent Linux distributions.

+--------------+----------+
| Package      | Version  |
+==============+==========+
| vala         | >=0.56   |
+--------------+----------+
| python       | >=3.8    |
+--------------+----------+
| meson        | >=0.64   |
+--------------+----------+
| ninja        | >=1.10   |
+--------------+----------+
| glib-2.0     | >=2.80   |
+--------------+----------+
| gobject-2.0  | >=2.80   |
+--------------+----------+
| gio-2.0      | >=2.80   |
+--------------+----------+
| gio-unix-2.0 | >=2.80   |
+--------------+----------+
| libsoup-2.4  | >=2.74   |
+--------------+----------+

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

    meson setup build
    ninja -C build

Install
-------

The framework can be installed for system-wide availability.

.. code-block:: bash

    sudo ninja -C build install

Once installed, VSGI implementations will be looked up into ``${prefix}/${libdir}/vsgi-0.4/servers``.
This path can be changed by setting the ``VSGI_SERVER_PATH`` environment
variable.

Run the tests
--------------

.. code-block:: bash

    meson test -C build --num-processes=1

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
