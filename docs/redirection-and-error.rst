Redirection and Error
=====================

Redirection, client and server errors are handled via a simple `exception`_
mechanism.

.. _exception: https://wiki.gnome.org/Projects/Vala/Manual/Errors

In a :doc:`route` callback, you may throw any of ``Redirection``,
``ClientError`` and ``ServerError`` predefined error domains rather than
setting the status and returning from the function.

The :doc:`router` handler will automatically catch these special errors and set
the appropriate status code in the response for your convenience.

Redirection (3xx)
-----------------

To perform a redirection, you have to throw a ``Redirection`` error and
use the message as a redirect URL.

.. code:: vala

    app.get ("user/<id>/save", (req, res) => {
        var user = User (req.params["id"]);

        if (user.save ())
            throw new Redirection.MOVED_TEMPORAIRLY ("/user/%u".printf (user.id));
    });

Client (4xx) and server (5xx) error
-----------------------------------

Just like for redirection, client and server errors are thrown.

Errors are predefined in ``ClientError`` and ``ServerError``
enumerations.

.. code:: vala

    app.get ("not-found", (req, res) => {
        throw new ClientError.NOT_FOUND ("The requested URI was not found.");
    });

Errors in next
--------------

The ``next`` continuation is designed to throw these specific errors so that
the :doc:`router` can handle them properly.

.. code:: vala

    app.get ("", (req, res, next) => {
        next (); // will throw a 404
    });

    app.get ("", (req, res) => {
        throw new ClientError.NOT_FOUND ("");
    });

Custom handling for status
--------------------------

To do custom handling for specific status, bind a callback to the ``teardown``
signal, it is executed after the processing of a client request.

.. code:: vala

    app.teardown.connect ((req, res) => {
        if (res.status == Soup.Status.NOT_FOUND) {
            // produce a 404 page...
        }
    });
