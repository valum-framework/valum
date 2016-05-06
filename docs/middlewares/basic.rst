Basic
=====

.. versionadded:: 0.3

Previously know under the name of *default handling*, the ``basic`` middleware
provide a conforming handling of raised status codes as described in the
:doc:`../redirection-and-error` document.

It aims at providing sane defaults for a top-level middleware.

::

    app.use (basic ());

    app.get ("/", () => {
        throw new Success.CREATED ("/resource/id");
    });

If an error is caught, it will perform the following tasks:

1.  assign an appropriate status code (500 for other errors)
2.  setup required headers (eg. `Location` for a redirection)
3.  produce a payload based on the message if required and not already used for
    a header

The payload will have the ``text/plain`` content type encoded with ``UTF-8``.

For privacy and security reason, non-status errors (eg. ``IOError``) will not
be used for the payload. To enable that for specific errors, it's possible to
convert them into into a raised status, preferably a ``500 Internal Server Error``.

::

    app.use (() => {
        try {
            return next ();
        } catch (IOError err) {
            throw new ServerError.INTERNAL_SERVER_ERROR (err.message);
        }
    })

