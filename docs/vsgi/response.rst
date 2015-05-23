Response
========

Responses are representing resources requested by a client. They are actively
streamed across the network, preferably using non-blocking asynchronous I/O.

Any operations on a response must eventually invoke ``end``, this is how it is
figured out that the response has completed its processing and resources
associated to it can be released. This enables the possibility to keep
a reference to the response in `AsyncResult`.

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

In GIO, streams are automatically closed when they get out of sight due
to reference counting. This is a particulary useful behiaviour for
asynchronous operations as references to requests or responses will
persist in a callback.

You do not have to close your streams (in general), but it can be a
useful to:

-  avoid undesired read or write operation
-  release the stream if it's not involved in a expensive processing

This is a typical example where closing the response manually will have
a great incidence on the application throughput.

.. code:: vala

    app.get("", (req, res) => {
        res.write ("You should receive an email shortly...".data);
        res.close (); // you can even use close_async

        // send a success mail
        Mailer.send ("johndoe@example.com", "Had to close that stream mate!");
    });

End the response
---------------
