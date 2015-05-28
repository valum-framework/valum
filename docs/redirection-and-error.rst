Redirection and Error
=====================

Redirection, client and server errors are handled via a simple `exception`_
mechanism.

.. _exception: https://wiki.gnome.org/Projects/Vala/Manual/Errors

In a :doc:`route` callback, you may throw any of ``Redirection``,
``ClientError`` and ``ServerError`` predefined error domains rather than
setting the status and returning from the function.

It is possible to connect a callback on the :doc:`router` to handle a specific
status code. Otherwise, the router will simply set the status code in the
response and set headers for specific errors.

.. code:: vala

    app.status (Soup.Status.PERMANENT, (req, res) => {
        res.status = Soup.Status.PERMANENT;
    });

The error message may be used to fill specific :doc:`vsgi/response` headers.
The following table describe how the router deal with specific error messages.

+--------------------------------+----------+
| Error                          | Header   |
+================================+==========+
| Redirection.*                  | Location |
+--------------------------------+----------+
| ClientError.METHOD_NOT_ALLOWED | Accept   |
+--------------------------------+----------+

Redirection (3xx)
-----------------

To perform a redirection, you have to throw a ``Redirection`` error and use the
message as a redirect URL. The :doc:`router` will automatically set the
``Location`` header accordingly.

Redirections are enumerated in ``Redirection`` enumeration.

.. code:: vala

    app.get ("user/<id>/save", (req, res) => {
        var user = User (req.params["id"]);

        if (user.save ())
            throw new Redirection.MOVED_TEMPORAIRLY ("/user/%u".printf (user.id));
    });

Client (4xx) and server (5xx) error
-----------------------------------

Like for redirections, client and server errors are thrown. Errors are
predefined in ``ClientError`` and ``ServerError`` enumerations.

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
