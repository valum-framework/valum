Request
=======

Represents an incoming HTTP request to your application to which you have to
provide a :doc:`response`.

Method
------

The ``Request`` class provides constants for the following HTTP methods:

-  ``OPTIONS``
-  ``GET``
-  ``HEAD``
-  ``POST``
-  ``PUT``
-  ``DELETE``
-  ``TRACE``
-  ``CONNECT``
-  ``PATCH``

Additionnaly, an array of HTTP methods ``Request.METHODS`` is providen to list
all supported HTTP methods by VSGI.

These can be conveniently used in :doc:`../router` functions to avoid using
plain strings to describe standard HTTP methods.

.. code:: vala

    app.method (Request.GET, "", (req, res) => {
        // ...
    });

Request parameters
------------------

.. deprecated:: 0.2

    Use the routing stack described in the :doc:`../router` documentation.

The request parameters are stored in a `GLib.HashTable`_ of ``string`` to
``string`` and can be accessed from the ``Request.params`` property. It's used
as a general metadata storage for requests.

.. _Glib.HashTable: http://valadoc.org/#!api=glib-2.0/GLib.HashTable

.. code:: vala

    app.get ("<int:id>", (req, res) => {
        var id = req.params["id"];
    });

It is used to store named captures from rule and regular expression
:doc:`../route` and as a general storage for custom matcher.

Request parameters are metadata extracted by the ``Route.MatcherCallback`` that
matched the request you are handling. They can contain pretty much anything
since a matcher can be any function accepting a ``Request`` instance.

The parameter defaults to ``null`` if it is not populated.

.. code:: vala

    app.get ("", (req, res) => {
        // req.params == null
    });

Headers
-------

Request headers are implemented with `Soup.MessageHeaders`_ and can be accessed
from the ``headers`` property.

.. _Soup.MessageHeaders: http://valadoc.org/#!api=libsoup-2.4/Soup.MessageHeaders

.. code:: vala

    app.get ("", (req, res) => {
        var accept = req.headers.get_one ("Accept");
    });

Body
----

Request body is streamed directly from the instance as it inherit from
`GLib.InputStream`_.

.. _GLib.InputStream: http://valadoc.org/#!api=gio-2.0/GLib.InputStream

`Soup.Form`_ can be used to parse ``application/x-www-form-urlencoded`` format.

.. _Soup.Form: http://valadoc.org/#!api=libsoup-2.4/Soup.Form

.. code:: vala

    app.post ("", (req, res) => {
        var buffer = new MemoryOutputStream.resizable ();

        // consume the request body in the stream
        buffer.splice (req.body, OutputStreamSpliceFlags.CLOSE_SOURCE);

        // consume it asynchronously
        buffer.splice_async.begin (req.body,
                                   OutputStreamSpliceFlags.CLOSE_SOURCE,
                                   Priority.DEFAULT,
                                   null,
                                   (obj, result) => {
            var consumed = buffer.splice_async.end (result);

            // decode the data
            var data = Soup.Form.decode (buffer.data);
        })
    });

Implementation will typically consume the status line, headers and newline that
separates the headers from the body in the base stream at construct time. It
also guarantee that the body has been decoded if any transfer encoding were
applied for the transport.

If the content is encoded with the ``Content-Encoding`` header, it is the
responsibility of your application to decode it properly. VSGI provides common
:doc:`converters` to simplify the task.

The ``body`` property can be setted to perform filtering or redirection. This
example show charset conversion using `GLib.CharsetConverter`_.

.. _GLib.CharsetConverter: http://valadoc.org/#!api=gio-2.0/GLib.CharsetConverter.CharsetConverter

.. code:: vala

    app.get ("", (req, res) => {
        req.body = new ConverterInputStream (req.body, new CharsetConverter ("utf-8", "ascii"));

        var reader = new DataInputStream (req.body);

        // pipe the request body in the response body
        res.splice (req, OutputStreamSpliceFlags.CLOSE_SOURCE);
    });

Multipart body
~~~~~~~~~~~~~~

Multipart body support is planned in a future minor release, more information
on `issue #81`_.

.. _issue #81: https://github.com/valum-framework/valum/issues/81

Closing the request
-------------------

When you are done, it is generally a good thing to close the request and
depending on the VSGI implementations, this could have great benefits such as
freeing a file resource.

