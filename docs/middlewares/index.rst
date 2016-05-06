Middlewares
===========

Middlewares are reusable pieces of processing that can perform various work
from authentication to the delivery of a static resource.

.. toctree::

    basepath
    basic
    decode
    server-sent-events
    status
    subdomain

The typical way of declaring them involve closures. It is parametrized and
returned to perform a specific task:

::

    public HandlerCallback middleware (/* parameters here */) {
        return (req, res, next, ctx) => {
            var referer = req.headers.get_one ("Referer");
            ctx["referer"] = new Soup.URI (referer);
            return next ();
        };
    }

The following example shows a middleware that provide a compressed stream over
the :doc:`../vsgi/response` body.

::

    app.use ((req, res, next) => {
        res.headers.append ("Content-Encoding", "gzip");
        res.convert (new ZLibCompressor (ZlibCompressorFormat.GZIP));
        return next ();
    });

    app.get ("/home", (req, res) => {
        return res.expand_utf8 ("Hello world!"); // transparently compress the output
    });

If this is wrapped in a function, which is typically the case, it can even be
used directly from the handler.

::

    HandlerCallback compress = (req, res, next) => {
        res.headers.append ("Content-Encoding", "gzip");
        res.convert (new ZLibCompressor (ZlibCompressorFormat.GZIP));
        return next ();
    };

    app.get ("/home", compress);

    app.get ("/home", (req, res) => {
        return res.expand_utf8 ("Hello world!");
    });

Alternatively, a middleware can be used directly instead of being attached to
a ``Route``, the processing will happen in a ``NextCallback``.

::

    app.get ("/home", (req, res, next, context) => {
        return compress (req, res, (req, res) => {
            return res.expand_utf8 ("Hello world!");
        }, new Context.with_parent (context));
    });

Forward
~~~~~~~

One typical pattern is to supply a ``HandlerCallback`` that is forwarded on
success (or any other event) like it's the case for the ``accept`` middleware.

.. code:: vala

    app.get ("", accept ("text/xml", (req, res) => {
        res.body.write_all ("<a>b</a>".data, null);
    }), (req, res) => {
        throw new ClientError.NOT_ACCEPTABLE ("We're only producing 'text/xml here!");
    });
