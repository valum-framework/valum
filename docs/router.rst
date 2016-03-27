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
        return next ();
    });

Routing context
---------------

During the routing, states can obtained from a previous handler or passed to
the next one using the routing context.

Keys are resolved recursively in the tree of context by looking at the parent
context if it's missing.

::

    app.get ("/", (req, res, next, context) => {
        context["some key"] = "some value";
        return next ();
    });

    app.get ("/", (req, res, next, context) => {
        var some_value = context["some key"]; // or context.parent["some key"]
        return return res.body.write_all (some_value.data, null);
    });

HTTP methods
------------

.. versionchanged:: 0.3

    Rule helpers (e.g. ``get``, ``post``, ``rule``) must explicitly be provided
    with a leading slash.

Callback can be connected to HTTP methods via a list of helpers having the
``HandlerCallback`` delegate signature:

::

    app.get ("/rule", (req, res, next) => { return false; });

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

    app.post ("/login", (req, res) => {
        var buffer = new MemoryOutputStream.resizable ();

        // consume the request body
        buffer.splice (req.body, OutputStreamSpliceFlags.CLOSE_SOURCE);

        var data = Soup.Form.decode ((string) buffer.get_data ());

        var username = data["username"];
        var password = data["password"];

        // assuming you have a session implementation in your app
        var session = new Session.authenticated_by (username, password);

        return true;
    });

It is also possible to use a custom HTTP method via the ``method``
function.

::

    app.method ("METHOD", "/rule", (req, res) => {});

:doc:`vsgi/request` provide an enumeration of HTTP methods for your
convenience.

::

    app.method (Request.GET, "/rule", (req, res) => {});

Multiple methods can be captured with ``methods``:

::

    app.methods (Request.GET, Request.POST, "", (req, res) => {
        // matches GET and POST
    });

Regular expression
------------------

.. versionchanged:: 0.3

    The regex helper must be provided with an explicit leading slash.

::

    app.regex (new Regex ("/home/"), (req, res) => {
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
        return next ();
    });

    app.status (Soup.Status.NOT_FOUND, (req, res) => {
        res.status = 404;
        return res.expand_utf8 ("Not found!");
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

    app.get ("/", (req, res) => {
        throw new IOError.FAILED ("I/O failed some some reason.");
    });

::

    app.get ("/", (req, res) => {
        res.expand_utf8_async ("Hello world!", null, () => {
            app.invoke (req, res, () => {
                throw new IOError.FAILED ("I/O failed undesirably.")
            });
        });
        return true;
    });

If the routing context is lost, any operation can still be performed within
``Router.invoke``

Scoping
-------

.. versionchanged:: 0.3

    The scope feature does not include a slash, instead you should scope with
    a leading slash like shown in the following examples.

Scoping is a powerful prefixing mechanism for rules and regular expressions.
Route declarations within a scope will be prefixed by ``<scope>``.

The ``Router`` maintains a scope stack so that when the program flow enter
a scope, it pushes the fragment on top of that stack and pops it when it exits.

::

    app.scope ("/admin", (admin) => {
        // admin is a scoped Router
        app.get ("/users", (req, res) => {
            // matches /admin/users
        });
    });

    app.get ("/users", (req, res) => {
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
            get ("/", view);
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

    app.rule (Method.ALL, "/admin/*", new AdminRouter ().handle);

Next
----

The :doc:`route` handler takes a callback as an optional third argument. This
callback is a continuation that will continue the routing process to the next
matching route.

::

    app.get ("/", (req, res, next) => {
        message ("pre");
        return next (); // keep routing
    });

    app.get ("/", (req, res) => {
        // this is invoked!
    });

Converters
~~~~~~~~~~

:doc:`vsgi/converters` can be applied on both the :doc:`vsgi/request` and
:doc:`vsgi/response` objects in order to filter the consumed or produced
payload.

::

    app.get ("/", (req, res, next) => {
        res.headers.append ("Content-Encoding", "gzip");
        res.convert (new ZlibCompressor (ZlibCompressorFormat.GZIP));
        return next ();
    });

    app.get ("/", (req, res) => {
        // res is transparently gzipped
    })

Sequence
--------

:doc:`route` has a ``then`` function that can be used to produce to sequence
handlers for a common matcher. It can be used to create a pipeline of
processing for a resource using middlewares.

::

    app.get ("/admin", (req, res, next) => {
        // authenticate user...
        return next ();
    }).then ((req, res, next) => {
        // produce sensitive data...
        return next ();
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

    app.get ("/", (req, res, next) => {
        res.expand_utf8_async.begin ("Hello world!", Priority.DEFAULT, null, () => {
            app.invoke (req, res, next);
        });
        return true;
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
        return res.expand_utf8 ("<p>%s</p>".printf (context["message"].get_string ()));
    });

Middleware
----------

Middlewares are reusable pieces of processing that can perform various work
from authentication to the delivery of a static resource. They are described in
the :doc:`middlewares/index` document.

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
the :doc:`vsgi/response` body.

::

    app.use ((req, res, next) => {
        res.headers.replace ("Content-Encoding", "gzip");
        return next (req, new ConvertedResponse (res, new ZLibCompressor (ZlibCompressorFormat.GZIP)));
    });

    app.get ("/home", (req, res) => {
        return res.expand_utf8 ("Hello world!"); // transparently compress the output
    });

If this is wrapped in a function, which is typically the case, it can even be
used directly from the handler.

::

    HandlerCallback compress = (req, res, next) => {
        res.headers.replace ("Content-Encoding", "gzip");
        return next (req, new ConvertedResponse (res, new ZLibCompressor (ZlibCompressorFormat.GZIP));
    };

    app.get ("/home", compress);

    app.get ("/home", (req, res) => {
        return res.expand_utf8 ("Hello world!");
    });

Alternatively, a middleware can be used directly instead of being attached to
a :doc:`route`, the processing will happen in a ``NextCallback``.

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
