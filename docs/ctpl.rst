CTPL
====

Valum provides `CTPL`_ integration as a basic view engine.

.. _CTPL: http://ctpl.tuxfamily.org/doc/unstable/ctpl-CtplEnviron.html

Three primitive types and one composite type are supported:

-  ``int``
-  ``float``
-  ``string``
-  ``array`` of preceding types (but not of ``array``)

Creating views
--------------

The ``View`` class provides constructors to create views from ``string``, file
path, resources and `GLib.InputStream`_.

.. _GLib.InputStream: http://valadoc.org/#!api=gio-2.0/GLib.InputStream

The simplest way to load a template is to use a ``string`` containing it.

.. code:: vala

    var template = new View.from_string ("{a}");

.. note::

    Resources should be loaded relatively to the `resource base path`_
    available in :doc:`vsgi/server/index`.

.. code:: vala

    var template = new View.from_path ("path/to/your/template.tpl");

.. _resource base path: http://valadoc.org/#!api=gio-2.0/GLib.Application.resource_base_path

It is a good practice to bundle static data in the executable using the
`GLib.Resource`_ API. This approach is covered in the
:doc:`recipes/static-resource` document.

.. _GLib.Resource: http://valadoc.org/#!api=gio-2.0/GLib.Resource

.. code:: vala

    var template = new View.from_stream (resources_open_stream ("/your/template.tpl"));

Templates can be loaded directly from global resources using
``View.from_resources``. If you need to load templates from external resources
bundle, use one of the preceding constructors.

.. code:: vala

    var template = new View.from_resources ("/your/template.tpl");

Environment
-----------

A ``View`` instance provides an `Ctpl.Environ`_ environment from which you can
push and pop variables of various types.

.. _Ctpl.Environ: http://ctpl.tuxfamily.org/doc/unstable/ctpl-CtplEnviron.html

.. code:: vala

    var template = new View.from_string ("{a}");

    template.environment.push_int ("a", 1);

Helpers are provided for pushing `GLib.HashTable`_, `Gee.Collection`_,
`Gee.Map`_ and `Gee.MultiMap`_ as well as array of ``double``, ``long`` and
``string``.

.. code:: vala

    double[] dbs = {8.2, 12.3, 2};

    template.push_string ("key", "value");
    template.push_doubles ("key", dbs);

`GLib.HashTable`_, `Gee.Map`_ and `Gee.MultiMap`_ are pushed by pushing all
their entries ony-by-one. Generated environment keys are the simple
concatenation of the provided key, a underscore (``_``) and the entry key.

.. code:: vala

    var map = new HashMap<string, string> ();

    map["key"]  = "value";
    map["key2"] = "value2";

    template.push_map ("map", map); // map_key and map_key2 will be pushed

.. _GLib.HashTable: http://valadoc.org/#!api=glib-2.0/GLib.HashTable
.. _Gee.Collection: http://valadoc.org/#!api=gee-0.10/Gee.Collection
.. _Gee.Map: http://valadoc.org/#!api=gee-0.10/Gee.Map
.. _Gee.MultiMap: http://valadoc.org/#!api=gee-0.10/Gee.MultiMap

Streaming views
---------------

The best way of rendering a view is by streaming it directly into
a :doc:`vsgi/response` instance with the ``to_stream`` function. This way, your
application can produce very big output efficiently.

.. code:: vala

    app.get ("", (req, res) => {
        var template = new View.from_string ("");
        template.to_stream (res.body);
    });

It is unfortunately not possible to stream with non-blocking I/O due to the
design of CTPL. The only possibility would be to dump the template in
a temporary `GLib.MemoryOutputStream`_ and then splice it asynchronously in the
response body.

.. _GLib.MemoryOutputStream: http://valadoc.org/#!api=gio-2.0/GLib.MemoryOutputStream

.. code:: vala

    app.get ("", (req, res) => {
        var template = new View.from_string ("");
        var buffer = new MemoryOutputStream.resizable ();

        // blocking on memory I/O
        template.to_stream (buffer);

        var buffer_reader = new MemoryInputStream (buffer.data);

        // non-blocking on network I/O
        res.body.splice_async.begin (buffer_reader,
                                     OutputStreamSpliceFlags.CLOSE_SOURCE,
                                     Priority.DEFAULT,
                                     null,
                                     (obj, result) => {
            var spliced = res.body.splice_async.end (result);
        });
    });

It would be roughly equivalent and shorter to write the result of
``View.to_string`` with `GLib.OutputStream.write_all_async`_ as it already
accumulate the produced stream in-memory:

.. _GLib.OutputStream.write_all_async: http://valadoc.org/#!api=gio-2.0/GLib.OutputStream.write_all_async

.. code:: vala

    app.get ("", (req, res) => {
        var template = new View.from_string ("");

        res.body.write_all_async.begin (template.to_string ().data,
                                        Priority.DEFAULT,
                                        null,
                                        (obj, result) => {
            var written = res.body.write_all_async.end (result);
        });
    });
