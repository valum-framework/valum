Safely
======

Yet very simple, the :valadoc:`valum-0.3/Valum.safely` middleware provide
a powerful way of discovering possible error conditions and handle them
locally.

Only status defined in :doc:`../redirection-and-error` are leaked: the compiler
will warn for all other unhandled errors.

::

    app.get ("/", safely ((req, res, next, ctx) => {
        try {
            res.expand_utf8 ("Hello world!");
        } catch (IOError err) {
            critical (err.message);
            return false;
        }
    });
