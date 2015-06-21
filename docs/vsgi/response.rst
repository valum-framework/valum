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
    })

Headers
-------

The response headers can be accessed as a `Soup.MessageHeaders`_ from the
``headers`` property.

.. _Soup.MessageHeaders: http://valadoc.org/#!api=libsoup-2.4/Soup.MessageHeaders

.. code:: vala

    app.get ("", (req, res) => {
        res.headers.set_content_type ("text/plain");
    })

Cookies
-------

Cookies can be written to the client using the ``cookies`` property. If you
need to replace only a specific cookie, you should append it to the response
headers.

.. code:: vala

    app.get ("", (req, res) => {
        var new_cookies = new GLib.SList<Soup.Cookie> ();
        res.cookies = new_cookies;
    });

Body
----

The body of a response is streamed directly in the instance since it inherits
from `GLib.OutputStream`_.

.. _GLib.OutputStream: http://valadoc.org/#!api=gio-2.0/GLib.OutputStream

.. code:: vala

    app.get ("", (req, res) => {
        res.write ("Hello world!".data);
    });

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
        res.write ("You should receive an email shortly...".data);
        res.close (); // you can even use close_async

        // send a success mail
        Mailer.send ("johndoe@example.com", "Had to close that stream mate!");
    });

This is an example of asynchronously closing the response body to improve I/O
performances.

.. code:: vala

    app.get ("", (req, res) => {
        res.body.close_async (Priority.DEFAULT, null)
    });

When operating asynchronously, the connection stream will be closed before the
response body, which may result in a corrupted response. It is important to
close the body manually to avoid such situation.

.. code:: vala

    app.get ("", (req, res) => {
        res.body.write_async ("Hello world!".data,
                              Priority.DEFAULT,
                              null, (body, result) => {
            body.close (); // explicitly close
        })
    })

If you splice, you can specify the `OutputStreamSpliceFlags.CLOSE_TARGET`_ flag
to perform that operation automatically.

.. _OutputStreamSpliceFlags.CLOSE_TARGET: http://valadoc.org/#!api=gio-2.0/GLib.OutputStreamSpliceFlags.CLOSE_TARGET

.. code:: vala

    app.get ("", (req, res) => {
        // pipe the request body into the response
        res.body.splice_async (req.body,
                               OutputStreamSpliceFlags.CLOSE_TARGET,
                               Priority.DEFAULT,
                               null);
    });

