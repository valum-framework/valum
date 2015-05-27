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
path and ``InputStream``.

.. code:: vala

    var template = new View.from_string ("{a}");

.. code:: vala

    var template = new View.from_path ("path/to/your/template.tpl");

It is a good practice to bundle static data in the executable using
`GLib.Resource`_. This practice is covered in the
:doc:`recipes/static-resource` document.

.. _GLib.Resource: http://valadoc.org/#!api=gio-2.0/GLib.Resource

.. code:: vala

    var template = new View.from_stream (resources_open_stream ("/your/template.tpl"));

Environment
-----------

A ``View`` instance provides an `Ctpl.Environ`_ environment from which you can
push and pop variables.

.. _Ctpl.Environ: http://ctpl.tuxfamily.org/doc/unstable/ctpl-CtplEnviron.html

.. code:: vala

    var template = new View.from_string ("{a}");

    template.environment.push_int ("a", 1);

Valum provides helpers for dumping `GLib.HashTable`_, `Gee.Collection`_,
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

    map["key"] = "value";
    map["key2"] = "value2";

    template.push_map ("map", map); // map_key and map_key2 will be pushed

.. _GLib.HashTable: http://valadoc.org/#!api=glib-2.0/GLib.HashTable
.. _Gee.Collection: http://valadoc.org/#!api=gee-0.10/Gee.Collection
.. _Gee.Map: http://valadoc.org/#!api=gee-0.10/Gee.Map
.. _Gee.MultiMap: http://valadoc.org/#!api=gee-0.10/Gee.MultiMap

Streaming views
---------------

The best way of rendering a view is by streaming it directly into
a :doc:`vsgi/response` instance with the ``stream`` function. This way, your
application can produce very big output efficiently.

.. code:: vala

    app.get ("", (req, res) => {
        var template = new View.from_string ("");
        template.stream (res.body);
    });

It is unfortunately not possible to stream with non-blocking I/O due to the
design of CTPL. The only possibility would be to dump the template in
a temporary ``MemoryOutputStream`` and then splice it asynchronously in the
response body.

.. code:: vala

    app.get ("", (req, res) => {
        var template = new View.from_string ("");
        var buffer = new MemoryOutputStream.resizable ();

        // blocking on memory I/O
        template.stream (buffer);

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
