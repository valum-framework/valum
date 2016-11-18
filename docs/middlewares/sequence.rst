Sequence
========

.. versionadded:: 0.3

The :valadoc:`valum-0.3/Valum.sequence` middleware provide a handy way of
chaining middlewares.

::

    app.post ("/", sequence (decode (), (req, res) => {
        // handle decoded payload
    }));

To chain more than two middlewares, one can chain a middleware with a sequence.

::

    app.get ("/admin", sequence ((req, res, next) => {
        // authenticate user...
        return next ();
    }, sequence ((req, res, next) => {
        // produce sensitive data...
        return next ();
    }, (req, res) => {
        // produce the response
    })));

Vala does not support varidic delegate arguments, which would be much more
convenient to describe a sequence.

