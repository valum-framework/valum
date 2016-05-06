Redirection and Error
=====================

Redirection, client and server errors are handled via a simple `exception`_
mechanism.

.. _exception: https://wiki.gnome.org/Projects/Vala/Manual/Errors

In a ``HandlerCallback``, you may throw any of ``Informational``, ``Success``,
``Redirection``, ``ClientError`` and ``ServerError`` predefined error domains
rather than setting the status and returning from the function.

It is possible to register a handler on the :doc:`router` to handle a specific
status code.

::

    app.use ((req, res, next) => {
        try {
            return next ();
        } catch (Redirection.PERMANENT red) {
            // handle a redirection...
        }
    }));

Default handling
----------------

.. versionchanged:: 0.3

    Default handling is not assured by the :doc:`middlewares/basic` middleware.

The :doc:`router` can be configured to handle raised status by setting the
response status code and headers appropriately.

::

    app.use (basic ());

    app.get ("/", () => {
        throw new ClientError.NOT_FOUND ("The request URI '/' was not found.");
    });

To handle status more elegantly, see the :doc:`middlewares/status` middleware.

::

    app.use (status (Status.NOT_FOUND, (req, res, next, ctx, err) => {
        // handle 'err' properly...
    }));

The error message may be used to fill a specific :doc:`vsgi/response` headers
or the response body. The following table describe how the router deal with
these cases.

+-----------------------------------+------------------+------------------------------------------+
| Status                            | Header           | Description                              |
+===================================+==================+==========================================+
| Informational.SWITCHING_PROTOCOLS | Upgrade          | Identifier of the protocol to use        |
+-----------------------------------+------------------+------------------------------------------+
| Success.CREATED                   | Location         | URL to the newly created resource        |
+-----------------------------------+------------------+------------------------------------------+
| Success.PARTIAL_CONTENT           | Range            | Range of the delivered resource in bytes |
+-----------------------------------+------------------+------------------------------------------+
| Redirection.MOVED_PERMANENTLY     | Location         | URL to perform the redirection           |
+-----------------------------------+------------------+------------------------------------------+
| Redirection.FOUND                 | Location         | URL of the found resource                |
+-----------------------------------+------------------+------------------------------------------+
| Redirection.SEE_OTHER             | Location         | URL of the alternative resource          |
+-----------------------------------+------------------+------------------------------------------+
| Redirection.USE_PROXY             | Location         | URL of the proxy                         |
+-----------------------------------+------------------+------------------------------------------+
| Redirection.TEMPORARY_REDIRECT    | Location         | URL to perform the redirection           |
+-----------------------------------+------------------+------------------------------------------+
| ClientError.UNAUTHORIZED          | WWW-Authenticate | Challenge for authentication             |
+-----------------------------------+------------------+------------------------------------------+
| ClientError.METHOD_NOT_ALLOWED    | Allow            | Comma-separated list of allowed methods  |
+-----------------------------------+------------------+------------------------------------------+
| ClientError.UPGRADE_REQUIRED      | Upgrade          | Identifier of the protocol to use        |
+-----------------------------------+------------------+------------------------------------------+

The following errors does not produce any payload:

-   ``Information.SWITCHING_PROTOCOLS``
-   ``Success.NO_CONTENT``
-   ``Success.RESET_CONTENT``
-   ``Success.NOT_MODIFIED``

For all other domains, the message will be used as a ``text/plain`` payload
encoded with ``UTF-8``.

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

::

    app.get ("/document/<int:id>", (req, res) => {
        // serve the document by its identifier...
    });

    app.put ("/document", (req, res) => {
        // create the document described by the request
        throw new Success.CREATED ("/document/%u".printf (id));
    });

Redirection (3xx)
-----------------

To perform a redirection, you have to throw a ``Redirection`` error and use the
message as a redirect URL. The :doc:`router` will automatically set the
``Location`` header accordingly.

Redirections are enumerated in ``Redirection`` error domain.

::

    app.get ("/user/<id>/save", (req, res) => {
        var user = User (req.params["id"]);

        if (user.save ())
            throw new Redirection.MOVED_TEMPORAIRLY ("/user/%u".printf (user.id));
    });

Client (4xx) and server (5xx) error
-----------------------------------

Like for redirections, client and server errors are thrown. Errors are
predefined in ``ClientError`` and ``ServerError`` error domains.

::

    app.get ("/not-found", (req, res) => {
        throw new ClientError.NOT_FOUND ("The requested URI was not found.");
    });

Errors in next
--------------

The ``next`` continuation is designed to throw these specific errors so that
the :doc:`router` can handle them properly.

::

    app.use ((req, res, next) => {
        try {
            return next ();
        } catch (ClientError.NOT_FOUND err) {
            // handle a 404...
        }
    });

    app.get ("/", (req, res, next) => {
        return next (); // will throw a 404
    });

    app.get ("/", (req, res) => {
        throw new ClientError.NOT_FOUND ("");
    });

