Resources
=========

GLib provides a powerful `resource api`_ for bundling static resources and
optionally link them in the executable.

.. _resource api: http://valadoc.org/#!api=gio-2.0/GLib.Resource

It has a few advantages:

-  resources can be compiled in the text segment of the executable, providing
   lightning fast loading time
-  resource api is simpler than file api and avoids IOError handling
-  application do not have to deal with its resource location or minimally if
   a separate bundle is used

This only applies to small and static resources as it will grow the size of the
executable. Also, if the resources are compiled in your executable, changing
them will require a recompilation.

Integration
-----------

Let's say your project has a few resources:

-  CTPL templates in a ``templates`` folder
-  CSS, JavaScript files in ``static`` folder

Setup a ``app.gresource.xml`` file that defines what resources will to
be bundled.

.. code-block:: xml

    <?xml version="1.0" encoding="UTF-8"?>
    <gresources>
      <gresource>
        <file>templates/home.html</file>
        <file>templates/404.html</file>
        <file>static/css/bootstrap.min.css</file>
      </gresource>
    </gresources>

You can test your setup with:

.. code-block:: bash

    glib-compile-resource app.gresource.xml

Latest version of ``waf`` automatically link ``*.gresource.xml`` if you load
the ``glib2`` plugin and add the file to your sources.

.. code-block:: python

    bld.load('glib2')

    bld.program(
       packages  = ['valum-0.1'],
       target    = 'app',
       source    = bld.path.ant_glob('**/*.vala') + ['app.gresource.xml'],
       uselib    = ['VALUM'])

The `app example`_ serves its static resources this way if you need a code
reference.

.. _app example: https://github.com/valum-framework/valum/tree/master/examples/app
