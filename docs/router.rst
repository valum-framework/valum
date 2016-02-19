Router
======

Router is the core component of Valum. It dispatches request to the right
handler and processes certain error conditions described in
:doc:`redirection-and-error`.

It initializes the :doc:`vsgi/response` with chunked encoding if the requester
uses HTTP/1.1 before dispatching it through the attached routes.

The ``Content-Type`` header should be set explicitly with
`Soup.MessageHeaders.set_content_type`_ based on the content transmitted to the
user agent.

.. _Soup.MessageHeaders.set_content_type: http://valadoc.org/#!api=libsoup-2.4/Soup.MessageHeaders.set_content_type

It can be performed automatically with ``Router.use``:

::

    app.use ((req, res, next) => {
        var params = new HashTable<string, string> (str_hash, str_equal);
        params["charset"] = "iso-8859-1";
        res.headers.set_content_type ("text/xhtml+xml", params);
        next (req, res);
    });

Routing context
---------------

During the routing, states can obtained from a previous handler or passed to
the next one using the routing context.

Keys are resolved recursively in the tree of context by looking at the parent
context if it's missing.

::

    app.get ("", (req, res, next, context) => {
        context["some key"] = "some value";
        next (req, res);
    });

    app.get ("", (req, res, next, context) => {
        var some_value = context["some key"]; // or context.parent["some key"]
    });

HTTP methods
------------

Callback can be connected to HTTP methods via a list of helpers having the
``HandlerCallback`` delegate signature:

::

    app.get ("rule", (req, res, next) => {});

The rule has to respect the rule syntax described in :doc:`route`. It will be
compiled down to a regex which named groups are made accessible in the context.

Helpers for the HTTP/1.1 protocol and the extra ``TRACE`` methods are included.

-  ``get``
-  ``post``
-  ``put``
-  ``delete``
-  ``connect``
-  ``trace``

This is an example of ``POST`` request handling using `Soup.Form`_ to decode
the ``application/x-www-form-urlencoded`` body of the :doc:`vsgi/request`.

.. _Soup.Form: http://valadoc.org/#!api=libsoup-2.4/Soup.Form

::

    app.post ("login", (req, res) => {
        var buffer = new MemoryOutputStream.resizable ();

        // consume the request body
        buffer.splice (req.body, OutputStreamSpliceFlags.CLOSE_SOURCE);

        var data = Soup.Form.decode ((string) buffer.get_data ());

        var username = data["username"];
        var password = data["password"];

        // assuming you have a session implementation in your app
        var session = new Session.authenticated_by (username, password);
    });

It is also possible to use a custom HTTP method via the ``method``
function.

::

    app.method ("METHOD", "rule", (req, res) => {});

:doc:`vsgi/request` provide an enumeration of HTTP methods for your
convenience.

::

    app.method (Request.GET, "rule", (req, res) => {});

Multiple methods can be captured with ``methods``:

::

    app.methods (Request.GET, Request.POST, "", (req, res) => {
        // matches GET and POST
    });

Regular expression
------------------

::

    app.regex (/home/, (req, res) => {
        // matches /home
    });

Matcher callback
----------------

Request can be matched by a simple callback typed by the ``MatcherCallback``
delegate.

.. warning::

    You have to be cautious if you want to fill request parameters and respect
    the `populate if match` rule, otherwise you will experience
    inconsistencies.

::

    app.matcher (Request.GET, (req) => { return req.uri.get_path () == "/home"; }, (req, res) => {
        // matches /home
    });

Status handling
---------------

Thrown status code can be handled by a ``HandlerCallback`` pretty much like how
typically matched requests are being handled.

The received :doc:`vsgi/request` and :doc:`vsgi/response` object are in the
same state they were when the status was thrown. The error message is bound to
the key ``message`` in the routing context.

::

    app.status (Soup.Status.NOT_FOUND, (req, res, next, context) => {
        // produce a 404 page...
        var message = context["message"].get_string ();
    });

Similarly to conventional request handling, the ``next`` continuation can be
invoked to jump to the next status handler in the queue.

::

    app.status (Soup.Status.NOT_FOUND, (req, res, next) => {
        next (req, res);
    });

    app.status (Soup.Status.NOT_FOUND, (req, res) => {
        res.status = 404;
        res.expand_utf8 ("Not found!", null);
    });

:doc:`redirection-and-error` can be thrown during the status handling, they
will be caught by the ``Router`` and processed accordingly.

::

    // turns any 404 into a permanent redirection
    app.status (Soup.Status.NOT_FOUND, (req, res) => {
        throw new Redirection.PERMANENT ("http://example.com");
    });

Error handling
--------------

.. versionadded:: 0.2.1

    Prior to this release, any unhandled error would crash the main loop
    iteration.

The router will capture any thrown `GLib.Error`_ and produce an internal error
accordingly. Similarly to status codes, errors are propagated in the
``HandlerCallback`` and ``NextCallback`` delegate signatures and can be handled
with a ``500`` handler.

.. _GLib.Error: http://valadoc.org/#!api=glib-2.0/GLib.Error

It provides a nice way to ignore passively unrecoverable errors.

::

    app.get ("", (req, res) => {
        throw new IOError.FAILED ("I/O failed some some reason.");
    });

::

    app.get ("", (req, res) => {
        res.expand_utf8_async ("Hello world!", null, () => {
            app.invoke (req, res, () => {
                throw new IOError.FAILED ("I/O failed undesirably.")
            });
        });
    });

If the routing context is lost, any operation can still be performed within
``Router.invoke``

Scoping
-------

Scoping is a powerful prefixing mechanism for rules and regular expressions.
Route declarations within a scope will be prefixed by ``<scope>/``. There is an
implicit initial scope so that all rules are automatically rooted with (``/``).

The ``Router`` maintains a scope stack so that when the program flow enter
a scope, it pushes the fragment on top of that stack and pops it when it exits.

The default separator is a ``/`` and it might become possible to change it in
a future release.

::

    app.scope ("admin", (admin) => {
        // admin is a scoped Router
        app.get ("users", (req, res) => {
            // matches /admin/users
        });
    });

    app.get ("users", (req, res) => {
        // matches /users
    });

Subrouting
----------

Since ``VSGI.ApplicationCallback`` is type compatible with ``HandlerCallback``,
it is possible to delegate request handling to another VSGI-compliant
application.

In particular, it is possible to treat ``Router.handle`` like any handling
callback.

.. note::

    This feature is a key design of the router and is intended to be used for
    a maximum inter-operability with other frameworks based on VSGI.

The following example delegates all ``GET`` requests to another router which
will process in isolation with its own routing context.

::

    var app = new Router ();
    var api = new Router ();

    // delegate all GET requests to api router
    app.get ("*", api.handle);

.. _cleaning-up-route-logic:

Cleaning up route logic
~~~~~~~~~~~~~~~~~~~~~~~

Performing a lot of route bindings can get messy, particularly if you want to
split an application several reusable modules. Encapsulation can be achieved by
subclassing ``Router`` and performing initialization in a ``construct`` block:

::

    public class AdminRouter : Router {

        construct {
            get ("", view);
            rule (Method.GET | Method.POST, "", edit);
        }

        public void view (Request req, Response res) {}

        public void edit (Request req, Response res) {}
    }

Using subrouting, it can be assembled to a parent router given a rule (or any
matching process described in :doc:`route`). This way, incoming request having
the ``/admin/`` path prefix will be delegated to the ``admin`` router.

::

    var app = new Router ();

    app.rule (Method.ALL, "admin/*", new AdminRouter ().handle);

Next
----

The :doc:`route` handler takes a callback as an optional third argument. This
callback is a continuation that will continue the routing process to the next
matching route.

::

    app.get ("", (req, res, next) => {
        message ("pre");
        next (req, res); // keep routing
    });

    app.get ("", (req, res) => {
        // this is invoked!
    });

Filters
~~~~~~~

:doc:`vsgi/filters` from VSGI are integrated by passing a filtered
:doc:`vsgi/request` or :doc:`vsgi/response` object to the next handler.

::

    app.get ("", (req, res, next) => {
        next (req, new ConvertedResponse (res, new ZlibCompressor (ZlibCompressorFormat.GZIP)));
    });

    app.get ("", (req, res) => {
        // res is transparently gzipped
    })

Sequence
--------

:doc:`route` has a ``then`` function that can be used to produce to sequence
handlers for a common matcher. It can be used to create a pipeline of
processing for a resource using handling middlewares.

::

    app.get ("admin", (req, res, next) => {
        // authenticate user...
        next (req, res);
    }).then ((req, res, next) => {
        // produce sensitive data...
        next (req, res);
    }).then ((req, res) => {
        // produce the response
    });

Invoke
------

It is possible to invoke a ``NextCallback`` in the routing context when the
latter is lost. This happens whenever you have to execute ``next`` in an async
callback.

The function provides an invocation context that handles thrown status code
with custom and default status code handlers. It constitute an entry point for
``handle`` where the next callback performs the actual routing.

::

    app.get ("", (req, res, next) => {
        res.expand_utf8_async ("Hello world!", Priority.DEFAULT, null, () => {
            app.invoke (req, res, next);
        });
    });

    app.use ((req, res) => {
        throw new ClientError.NOT_FOUND ("the requested resource was not found");
    });

    app.status (404, (req, res) => {
        // produce a 404 page...
    });

Similarly to ``handle``, this function can be used to perform something similar
to subrouting by executing a ``NextCallback`` in the context of another router.

The following example handles a situation where a client with the
``Accept: text/html`` header defined attempts to access an API that produces
responses designed for non-human client.

::

    var app = new Router ();
    var api = new Router ();

    api.matcher (accept ("text/html"), (req, res) => {a
        // let the app produce a human-readable response as the client accepts
        // 'text/html' response
        app.invoke (req, res, () => {
            throw ClientError.NOT_ACCEPTABLE ("this is an API");
        });
    });

    app.status (Status.NOT_ACCEPTABLE, (req, res, next, context) => {
        res.expand_utf8 ("<p>%s</p>".printf (context["message"].get_string ()), null);
    });

Middleware
----------

Anything that does not handle the user request, typically by invoking ``next``,
is considered to be a middleware. Two kind of middleware can coexist to provide
reusable matching and handling capabilities.

Matching middleware
~~~~~~~~~~~~~~~~~~~

These middlewares respect the ``Route.MatcherCallback`` delegate signature.

The following piece of code is a reusable and generic content negociator:

::

    public MatcherCallback accept (string content_type) {
        return (req) => {
            return req.headers.get_one ("Accept") == content_type;
        };
    }

It is not really powerful as it does not support fuzzy matching like
``application/*``, but it demonstrates the potential capabilities.

It can conveniently be used as a matcher callback to capture all requests that
accept the ``application/json`` content type as a response.

::

    app.matcher (accept ("application/json"), (req, res) => {
        // produce a JSON output...
    });

Handling middleware
~~~~~~~~~~~~~~~~~~~

These middlewares are reusable pieces of processing that can perform various
work from authentication to the delivery of a static resource.

It is possible for a handling middleware to pass a state to the next handling
route, allowing them to produce content that can be consumed instead of simply
processing the :doc:`vsgi/request` or :doc:`vsgi/response`.

A handling middleware can also pass a filtered :doc:`vsgi/request` or
:doc:`vsgi/response` objects using :doc:`vsgi/filters`,

These middlewares can be mounted on the routing queue with ``Router.use`` or
conditionally to a matching middleware.

::

    app.use ((req, res, next) => {
        // executed on every request
        next (req, res);
    });

The following example shows a middleware that provide a compressed stream over
the :doc:`vsgi/response` body.

::

    app.use ((req, res, next) => {
        res.headers.replace ("Content-Encoding", "gzip");
        next (req, new ConvertedResponse (res, new ZLibCompressor (ZlibCompressorFormat.GZIP)));
    });

    app.get ("home", (req, res) => {
        res.expand_utf8 ("Hello world!", null); // transparently compress the output
    });

If this is wrapped in a function, which is typically the case, it can even be
used directly from the handler.

::

    HandlerCallback compress = (req, res, next) => {
        res.headers.replace ("Content-Encoding", "gzip");
        next (req, new ConvertedResponse (res, new ZLibCompressor (ZlibCompressorFormat.GZIP));
    };

    app.get ("home", compress);

    app.get ("home", (req, res) => {
        res.expand_utf8 ("Hello world!", null);
    });

Alternatively, a handling middleware can be used directly instead of being
attached to a :doc:`route`, the processing will happen in a ``NextCallback``.

::

    app.get ("home", (req, res, next, context) => {
        compress (req, res, (req, res) => {
            res.expand_utf8 ("Hello world!", null);
        }, new Context.with_parent (context));
    });
