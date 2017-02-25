Middlewares
===========

Middlewares are reusable pieces of processing that can perform various work
from authentication to the delivery of a static resource.

.. toctree::

    authenticate
    basepath
    basic
    content-negotiation
    decode
    respond-with
    safely
    sequence
    server-sent-events
    static
    status
    subdomain
    websocket

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
a :valadoc:`valum-0.3/Valum.Route`, the processing will happen in
a :valadoc:`valum-0.3/Valum.NextCallback`.

::

    app.get ("/home", (req, res, next, context) => {
        return compress (req, res, (req, res) => {
            return res.expand_utf8 ("Hello world!");
        }, new Context.with_parent (context));
    });

Class-based
~~~~~~~~~~~

.. versionadded:: 0.4

In some scenarios, using purely callbacks can become messy and a class-based
approach would make a more efficient usage of Vala features.

The :valadoc:`valum-0.4/Valum.Middleware` class, which inherit from
:valadoc:`vsgi-0.4/VSGI.Handler`, can be used for this purpose.

::

    public class FooMiddleware : Middleware {

        public override bool fire (Request req, Response res, NextCallback next, Context ctx) {
            return res.expand_utf8 ("Hello world!");
        }
    }

The usage is really similar to regualar middleware, with the difference that
the ``fire`` function has to be passed to functions expecting a :valadoc:`valum-0.4/Valum.HandlerCallback`.

::

    var app = new Router ();

    app.use (new FooMiddleware ().fire);

Forward
~~~~~~~

.. versionadded:: 0.3

One typical middleware pattern is to take a continuation that is forwarded on
success (or any other event) with a single value like it's the case for the
:doc:`content-negotiation` middlewares.

This can be easily done with :valadoc:`valum-0.3/Valum.ForwardCallback<T>`. The
generic parameter specify the type of the forwarded value.

::

    public HandlerCallback accept (string content_types, ForwardCallback<string> forward) {
        return (req, res, next, ctx) => {
            // perform content negotiation and determine 'chosen_content_type'...
            return forward (req, res, next, ctx, chosen_content_type);
        };
    }

    app.get ("/", accept ("text/xml; application/json", (req, res, next, ctx, content_type) => {
        // produce a response according to 'content_type'...
    }));

Often, one would simply call the ``next`` continuation, so a :valadoc:`valum-0.3/Valum.forward`
definition is provided to do that. It is used as a default value for various
middlewares such that all the following examples are equivalent:

::

    app.use (accept ("text/html" () => {
        return next ();
    }));

    app.use (accept ("text/html", forward));

    app.use (accept ("text/html"));


To pass multiple values, it is preferable to explicitly declare them using
a delegate.

::

    public delegate bool ComplexForwardCallback (Request      req,
                                                 Response     res,
                                                 NextCallback next,
                                                 Context      ctx,
                                                 int          a,
                                                 int          b) throws Error;

