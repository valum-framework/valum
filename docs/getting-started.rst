Quickstart
==========

Assuming that Valum is built and installed correctly (view :doc:`installation`
for more details), you are ready to create your first application!

Simple 'Hello world!' application
---------------------------------

You can use this sample application and project structure as a basis. The full
`valum-framework/example`_ is available on GitHub and is kept up-to-date with
the latest release of the framework.

.. _valum-framework/example: https://github.com/valum-framework/example

::

    using Valum;
    using VSGI;

    var app = new Router ();

    app.get ("/", (req, res) => {
        res.headers.set_content_type ("text/plain", null);
        return res.expand_utf8 ("Hello world!");
    });

    Server.new ("http", handler: app).run ({"app", "--port", "3003"});

Typically, the ``run`` function contains CLI argument to make runtime the
parametrizable.

It is suggested to use the following structure for your project, but you can do
pretty much what you think is the best for your needs.

::

    build/
    src/
        app.vala

Building with valac
-------------------

Simple applications can be built directly with ``valac``:

.. code-block:: bash

    valac --pkg=valum-0.3 -o build/app src/app.vala

The ``vala`` program will build and run the produced binary, which is
convenient for testing:

.. code-block:: bash

    vala --pkg=valum-0.3 src/app.vala

Building with Meson
-------------------

`Meson`_ is highly-recommended for its simplicity and expressiveness. It's not
as flexible as waf, but it will handle most projects very well.

.. _Meson: http://mesonbuild.com/

.. code-block:: python

    project('example', 'c', 'vala')

    glib_dep = dependency('glib-2.0')
    gobject_dep = dependency('gobject-2.0')
    gio_dep = dependency('gio-2.0')
    soup_dep = dependency('libsoup-2.4')
    vsgi_dep = dependency('vsgi-0.3')   # or subproject('vsgi').get_variable('vsgi_dep')
    valum_dep = dependency('valum-0.3') # or subproject('valum').get_variable('valum_dep')

    executable('app', 'src/app.vala',
               dependencies: [glib_dep, gobject_dep, gio_dep, soup_dep, vsgi_dep, valum_dep])

.. code-block:: bash

    mkdir build && cd build
    meson ..
    ninja

To include Valum as a subproject, it is sufficient to clone the repository into
``subprojects/valum``.

Building with waf
-----------------

It is preferable to use a build system like `waf`_ to automate all this
process. Get a release of ``waf`` and copy this file under the name ``wscript``
at the root of your project.

.. _waf: https://code.google.com/p/waf/

.. code-block:: python

    def options(cfg):
        cfg.load('compiler_c')

    def configure(cfg):
        cfg.load('compiler_c vala')
        cfg.check_cfg(package='valum-0.3', uselib_store='VALUM', args='--libs --cflags')

    def build(bld):
        bld.load('compiler_c vala')
        bld.program(
            packages = 'valum-0.3',
            target   = 'app',
            source   = 'src/app.vala',
            use      = 'VALUM')

You should now be able to build by issuing the following commands:

.. code-block:: bash

    ./waf configure
    ./waf build

Running the example
-------------------

VSGI produces process-based applications that are either self-hosted or able to
communicate with a HTTP server according to a standardized protocol.

The :doc:`vsgi/server/http` implementation is self-hosting, so you just have to
run it and point your browser at http://127.0.0.1:3003 to see the result.

.. code-block:: bash

    ./build/app
