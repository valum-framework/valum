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

The request parameters are stored in a `GLib.HashTable`_ of ``string`` to
``string`` and can be accessed from the ``Request.params`` property. It's used
as a general metadata storage for requests.

.. _Glib.HashTable: http://valadoc.org/#!api=glib-2.0/GLib.HashTable<F37>

.. code:: vala

    app.get ("<int:id>", (req, res) => {
        var id = req.params["id"];
    });

It is used to store named captures from rule and regular expression
:doc:`../route` and as a general storage for custom matcher.

Request parameters are metadata extracted by the ``Route.Matcher`` that matched
the request you are handling. They can contain pretty much anything since
a matcher can be any function accepting a ``Request`` instance.

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

Cookies
-------

Cookies can be accessed as a `GLib.SList`_ of `Soup.Cookie`_ from the `cookies`
property or directly from the request headers.

.. _GLib.SList: http://valadoc.org/#!api=glib-2.0/GLib.SList
.. _Soup.Cookie: http://valadoc.org/#!api=libsoup-2.4/Soup.Cookie

.. code:: vala

    app.get ("", (req, res) => {
        for (var cookie : req.cookies) {
            res.write (cookie.get_name ().data);
        }

        // from the headers
        var cookies = req.headers.get_list ("Cookie");
    });

Body
----

Request body is streamed directly from the instance as it inherit from
`GLib.InputStream`_.

.. _GLib.InputStream: http://valadoc.org/#!api=gio-2.0/GLib.InputStream

.. code:: vala

    app.get ("", (req, res) => {
        var buffer = new uint8[24];
        req.read (buffer);
    });

Implementation will typically consume the status line, headers and newline that
separates the headers from the body. The body is left to your application to
interpret as it can contain pretty much anything.

Multipart body are not yet supported, but this is planned for the next minor
release.

Closing the request
-------------------

When you are done, it is generally a good thing to close the request and
depending on the VSGI implementations, this could have great benefits such as
freeing a file resource.

