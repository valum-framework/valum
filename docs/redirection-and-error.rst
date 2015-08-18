Redirection and Error
=====================

Redirection, client and server errors are handled via a simple `exception`_
mechanism.

.. _exception: https://wiki.gnome.org/Projects/Vala/Manual/Errors

In a ``HandlerCallback``, you may throw any of ``Informational``, ``Success``,
``Redirection``, ``ClientError`` and ``ServerError`` predefined error domains
rather than setting the status and returning from the function.

It is possible to register a handler on the :doc:`router` to handle a specific
status code. Otherwise, the router will simply set the status code in the
response and set its headers for specific status.

.. code:: vala

    app.status (Soup.Status.PERMANENT, (req, res) => {
        res.status = Soup.Status.PERMANENT;
    });

.. warning::

    The :doc:`router` assumes that the :doc:`vsgi/response` head has never been
    written in order to perform its default handling.

The error message may be used to fill a specific :doc:`vsgi/response` headers
or the response body. The following table describe how the router deal with
these cases.

+-----------------------------------+----------+------------------------------------------+
| Status                            | Header   | Description                              |
+===================================+==========+==========================================+
| Informational.SWITCHING_PROTOCOLS | Upgrade  |                                          |
+-----------------------------------+----------+------------------------------------------+
| Success.CREATED                   | Location | URI to the newly created resource        |
+-----------------------------------+----------+------------------------------------------+
| Success.PARTIAL_CONTENT           | Range    | Range of the delivered resource in bytes |
+-----------------------------------+----------+------------------------------------------+
| Redirection.*                     | Location | URI to perform the redirection           |
+-----------------------------------+----------+------------------------------------------+
| ClientError.METHOD_NOT_ALLOWED    | Accept   |                                          |
+-----------------------------------+----------+------------------------------------------+
| ClientError.UPGRADE_REQUIRED      | Upgrade  |                                          |
+-----------------------------------+----------+------------------------------------------+

.. note::

    If the error message is not intended for a specific response header, the
    message is automatically written in the body with ``Content-Type`` and
    ``Content-Length`` headers set appropriately.

The approach taken by Valum is to support at least all status defined by
libsoup-2.4 and those defined in RFC documents. If anything is missing, you can
add it and submit us a pull request.

Informational (1xx)
-------------------

Informational status are used to provide a in-between response for the
requested resource. The :doc:`vsgi/response` body must remain empty.

Informational status are enumerated in ``Informational`` error domain.

Success (2xx)
-------------

Success status tells the client that the request went well and provide
additional information about the resource. An example would be to throw
a ``Success.CREATED`` error to provide the location of the newly created
resource.

Successes are enumerated in ``Success`` error domain.

.. code:: vala

    app.get ("document/<int:id>", (req, res) => {
        // serve the document by its identifier...
    });

    app.put ("document", (req, res) => {
        // create the document described by the request
        throw new Success.CREATED ("/document/%u".printf (id));
    });

Redirection (3xx)
-----------------

To perform a redirection, you have to throw a ``Redirection`` error and use the
message as a redirect URL. The :doc:`router` will automatically set the
``Location`` header accordingly.

Redirections are enumerated in ``Redirection`` error domain.

.. code:: vala

    app.get ("user/<id>/save", (req, res) => {
        var user = User (req.params["id"]);

        if (user.save ())
            throw new Redirection.MOVED_TEMPORAIRLY ("/user/%u".printf (user.id));
    });

Client (4xx) and server (5xx) error
-----------------------------------

Like for redirections, client and server errors are thrown. Errors are
predefined in ``ClientError`` and ``ServerError`` error domains.

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
        next (req, res); // will throw a 404
    });

    app.get ("", (req, res) => {
        throw new ClientError.NOT_FOUND ("");
    });

During status handling, the error message will be pushed on the routing stack
as a ``string``.

.. code:: vala

    app.status (404, (req, res, next, stack) => {
        var message = stack.pop_tail ().get_string ();
    });
