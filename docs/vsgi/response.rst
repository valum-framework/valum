Response
========

Responses are representing resources requested by a client. They are actively
streamed across the network, preferably using non-blocking asynchronous I/O.

Status
------

The response status can be set with the ``status`` property. libsoup provides
an `enumeration of status`_.

.. _enumeration of status: http://valadoc.org/#!api=libsoup-2.4/Soup.Status

.. code:: vala

    app.get ("", (req, res) => {
        res.status = Soup.Status.MALFORMED;
    });

Headers
-------

The response headers can be accessed as a `Soup.MessageHeaders`_ from the
``headers`` property.

.. _Soup.MessageHeaders: http://valadoc.org/#!api=libsoup-2.4/Soup.MessageHeaders

.. code:: vala

    app.get ("", (req, res) => {
        res.headers.set_content_type ("text/plain");
    });

Body
----

The body of a response is accessed through the ``body`` property. It inherits
from `GLib.OutputStream` to provide streaming capabilities.

Status line and headers are sent the first time the property is accessed. It is
considered an error to modify them once the body has been accessed.

The transfer encoding is already handled by the VSGI implementation, so all you
have to do is set the ``Transfer-Encoding`` header properly.

.. _GLib.OutputStream: http://valadoc.org/#!api=gio-2.0/GLib.OutputStream

.. code:: vala

    app.get ("", (req, res) => {
        res.body.write ("Hello world!".data);
    });

It is possible to set the ``body`` property in order to filter or redirect it.
This can be used to implement gzipped content encoding or just dump the body in
a file stream for debugging.

.. code:: vala

    res.headers.replace ("Content-Encoding", "gzip");
    res.body = new ConverterOutputStream (res.body, new ZLibCompressor ());

Closing the response
--------------------

Response body is automatically closed as this behaviour is ensured by GIO when
a stream get out of scope. However you can still close it explicitly as it
provides few advantages:

-  avoid undesired read or write operation
-  release the stream if it's not involved in a expensive processing
-  closing the stream asynchronously with ``close_async`` can provide better
   performances

This is a typical example where closing the response manually will have
a great incidence on the application throughput.

.. code:: vala

    app.get("", (req, res) => {
        res.body.write ("You should receive an email shortly...".data);
        res.body.close (); // you can even use close_async

        // send a success mail
        Mailer.send ("johndoe@example.com", "Had to close that stream mate!");
    });

This is an example of asynchronously closing the response body to improve I/O
performances.

.. code:: vala

    app.get ("", (req, res) => {
        res.body.close_async (Priority.DEFAULT);
    });

When operating asynchronously, the connection stream will be closed before the
response body if the connection is freed. To avoid that behaviour, a reference
to either the :doc:`request` or response must persist until the operation ends.

.. code:: vala

    app.get ("", (req, res) => {
        res.body.write_async.begin ("Hello world!".data,
                                    Priority.DEFAULT,
                                    null, (body, result) => {
            // the reference to the response has persisted
            var written = res.body.write_async.end (result);
        });
    });

