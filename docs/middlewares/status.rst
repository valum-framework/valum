Status
======

Thrown status codes (see :doc:`../redirection-and-error`) can be handled with the
``status`` middleware.

The received :doc:`../vsgi/request` and :doc:`../vsgi/response` object are in
the same state they were when the status was thrown. An additional parameter
provide access to the actual `GLib.Error`_ object.

.. _GLib.Error: //

::

    app.use (status (Soup.Status.NOT_FOUND, (req, res, next, context, err) => {
        // produce a 404 page...
        var message = err.message;
    });

Similarly to conventional request handling, the ``next`` continuation can be
invoked to jump to the next status handler, which is found upstream in the
routing queue.

::

    app.status (Soup.Status.NOT_FOUND, (req, res) => {
        res.status = 404;
        return res.expand_utf8 ("Not found!");
    });

    app.status (Soup.Status.NOT_FOUND, (req, res, next) => {
        return next ();
    });

    app.get ("/", () => {
        throw new ClientError.NOT_FOUND ("");
    });

If an error is not handled, it will eventually be caught by the default status
handler, which produce a minimal response.

::

    // turns any 404 into a permanent redirection
    app.status (Soup.Status.NOT_FOUND, (req, res) => {
        throw new Redirection.PERMANENT ("http://example.com");
    });
