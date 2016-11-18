Status
======

Thrown status codes (see :doc:`../redirection-and-error`) can be handled with the
:valadoc:`valum-0.3/Valum.status` middleware.

The received :doc:`../vsgi/request` and :doc:`../vsgi/response` object are in
the same state they were when the status was thrown. An additional parameter
provide access to the actual :valadoc:`glib-2.0/GLib.Error` object.

::

    app.use (status (Soup.Status.NOT_FOUND, (req, res, next, context, err) => {
        // produce a 404 page...
        var message = err.message;
    });

To jump to the next status handler found upstream in the routing queue, just
throw the error. If the error can be resolved, you might want to try ``next``
once more.

::

    app.status (Soup.Status.NOT_FOUND, (req, res) => {
        res.status = 404;
        return res.expand_utf8 ("Not found!");
    });

    app.status (Soup.Status.NOT_FOUND, (req, res, next, ctx, err) => {
        return next (); // try to route again or jump upstream
    });

    app.use (() => {
        throw new ClientError.NOT_FOUND ("");
    });

If an error is not handled, it will eventually be caught by the default status
handler, which produce a minimal response.

::

    // turns any 404 into a permanent redirection
    app.status (Soup.Status.NOT_FOUND, (req, res) => {
        throw new Redirection.PERMANENT ("http://example.com");
    });
