Router
======

Router is the core component of Valum. It dispatches request to the right
handler and processes certain error conditions described in
:doc:`redirection-and-error`.

The router is constituted of a sequence of ``Route`` objects which may or may
not match incoming requests and perform the process described in their
handlers.

Route
-----

The most basic and explicit way of attaching a handler is ``Router.route``,
which attach the provided ``Route`` object to the sequence.

::

    app.route (new RuleRoute (Method.GET, "/", null, () => {}));

Route are simple objects which combine a matching and handling processes. The
following sections implicitly treat of route objects such such as ``RuleRoute``
and ``RegexRoute``.

Method
------

.. versionadded:: 0.3

The ``Method`` flag provide a list of HTTP methods and some useful masks used
into route definitions.

==================== =================================================
Flag                  Description
==================== =================================================
``Method.ALL``        all standard HTTP methods
``Method.OTHER``      any non-standard HTTP methods
``Method.ANY``        anything, including non-standard methods
``Method.PROVIDED``   indicate that the route provide its methods
``Method.META``       mask for all meta flags like ``Method.PROVIDED``
==================== =================================================

Using a flag makes it really convenient to capture multiple methods with the
``|`` binary operator.

::

    app.rule (Method.GET | Method.POST, "/", (req, res) => {
        // matches GET and POST
    });

``Method.GET`` is defined as ``Method.ONLY_GET | Method.HEAD`` such that
defining the former will also provide a ``HEAD`` implementation. In general,
it's recommended to check the method in order to skip a body that won't be
considered by the user agent.

::

    app.get ("/", () => {
        res.headers.set_content_type ("text/plain", null);
        if (req.method == Request.HEAD) {
            return res.end (); // skip unnecessary I/O
        }
        return res.expand_utf8 ("Hello world!");
    });

To provide only the ``GET`` part, use ``Method.ONLY_GET``.

::

    app.rule (Method.ONLY_GET, () => {
        res.headers.set_content_type ("text/plain", null);
        return res.expand_utf8 ("Hello world!");
    });

Non-standard method
~~~~~~~~~~~~~~~~~~~

To handle non-standard HTTP method, use the ``Method.OTHER`` along with an
explicit check.

::

    app.method (Method.OTHER, "/rule", (req, res) => {
        if (req.method != "CUSTOM")
            return next ();
    });

Introspection
~~~~~~~~~~~~~

The router introspect the route sequence to determine what methods are allowed
for a given URI and thus produce a nice ``Allow`` header. To mark a method as
*provided*, the ``Method.PROVIDED`` flag has to be used. This is automatically
done for the helpers and the ``Router.rule`` function described below.

Additionally, the ``OPTIONS`` and ``TRACE`` are automatically handled if not
specified for a path. The ``OPTIONS`` will produce a ``Allow`` header and
``TRACE`` will feedback the request into the response payload.

Use
---

.. versionadded:: 0.3

The simplest way to attach a handler is ``Router.use``, which unconditionally
apply the route on the request.

::

    app.use ((req, res, next) => {
        var params = new HashTable<string, string> (str_hash, str_equal);
        params["charset"] = "iso-8859-1";
        res.headers.set_content_type ("text/xhtml+xml", params);
        return next ();
    });

It is typically used to mount a :doc:`middlewares/index` on the router.

Asterisk
--------

.. versionadded:: 0.3

The special ``*`` URI is handled by the ``Router.asterisk`` helper. It is
typically used along with the ``OPTIONS`` method to provide a self-description
of the web service or application.

::

    app.asterisk (Method.OPTIONS, () => {
        return true;
    });

Rule
----

.. versionchanged:: 0.3

    Rule helpers (e.g. ``get``, ``post``, ``rule``) must explicitly be provided
    with a leading slash.

    The rule syntax has been greatly improved to support groups, optionals and
    wildcards.

The *de facto* way of attaching handler callbacks is based on the rule system.
The ``Router.rule`` as well as all HTTP method helpers use it.

::

    app.rule (Method.ALL, "/rule" (req, res) => {
        return true;
    });

The syntax for rules is given by the following EBNF grammar:

.. literalinclude:: rule.ebnf
    :language: ebnf

Remarks
~~~~~~~

-  a piece is a single character, so ``/users/?`` only indicates that the ``/``
   is optional
-  the wildcard ``*`` matches anything, just like the ``.*`` regular expression

The following table show valid rules and their corresponding regular
expressions. Note that rules are matching the whole path as they are
automatically anchored.

===================== ===========================
Rule                  Regular expression
===================== ===========================
``/user``             ``^/user$``
``/user/<id>``        ``^/user/(?<id>\w+)$``
``/user/<int:id>``    ``^/user/(?<id>\d+)$``
``/user(/<int:id>)?`` ``^/user(?:/(?<id>\d+))?$``
===================== ===========================

Types
~~~~~

Valum provides built-in types initialized in the :doc:`router` constructor. The
following table details these types and what they match.

+------------+-----------------------+--------------------------------------+
| Type       | Regex                 | Description                          |
+============+=======================+======================================+
| ``int``    | ``\d+``               | matches non-negative integers like a |
|            |                       | database primary key                 |
+------------+-----------------------+--------------------------------------+
| ``string`` | ``\w+``               | matches any word character           |
+------------+-----------------------+--------------------------------------+
| ``path``   | ``(?:\.?[\w/-\s/])+`` | matches a piece of route including   |
|            |                       | slashes, but not ``..``              |
+------------+-----------------------+--------------------------------------+

Undeclared types default to ``string``, which matches any word characters.

It is possible to specify or overwrite types using the ``types`` map in
:doc:`router`. This example will define the ``path`` type matching words and
slashes using a regular expression literal.

::

    app.register_type ("path", new Regex ("[\w/]+", RegexCompileFlags.OPTIMIZE));

If you would like ``ìnt`` to match negatives integer, you may just do:

::

    app.register_type ("int", new Regex ("-?\d+", RegexCompileFlags.OPTIMIZE));

Rule parameters are available from the routing context by their name.

::

    app.get ("/<controller>/<action>", (req, res, next, context) => {
        var controller = context["controller"].get_string ();
        var action     = context["action"].get_string ();
    });

Helpers
~~~~~~~

Helpers for the methods defined in the HTTP/1.1 protocol and the extra
``TRACE`` methods are included. The path is matched according to the rule
system defined previously.

::

    app.get ("/", (req, res) => {
        return res.expand_utf8 ("Hello world!");
    });

The following example deal with a ``POST`` request providing using `Soup.Form`_
to decode the payload.

.. _Soup.Form: http://valadoc.org/#!api=libsoup-2.4/Soup.Form

::

    app.post ("/login", (req, res) => {
        var data = Soup.Form.decode (req.flatten_utf8 ());

        var username = data["username"];
        var password = data["password"];

        // assuming you have a session implementation in your app
        var session = new Session.authenticated_by (username, password);

        return true;
    });

Regular expression
------------------

.. versionchanged:: 0.3

    The regex helper must be provided with an explicit leading slash.

If the rule system does not suit your needs, it is always possible to use
regular expression. Regular expression will be automatically scoped, anchored
and optimized.

::

    app.regex (Method.GET, new Regex ("/home/?", RegexCompileFlags.OPTIMIZE), (req, res) => {
        return res.body.write_all ("Matched using a regular expression.".data, true);
    });

Named captures are registered on the routing context.

::

    app.regex (new Regex ("/(?<word>\w+)", RegexCompileFlags.OPTIMIZE), (req, res, next, ctx) => {
        var word = ctx["word"].get_string ();
    });

Matcher callback
----------------

Request can be matched by a simple callback typed by the ``MatcherCallback``
delegate.

::

    app.matcher (Method.GET, (req) => { return req.uri.get_path () == "/home"; }, (req, res) => {
        // matches /home
    });

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

To literally mount an application on a prefix, see the
:doc:`middlewares/basepath` middleware.

Context
-------

.. versionadded:: 0.3

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

Next
----

.. versionchanged:: 0.3

    The ``next`` continuation does not take the request and response objects as
    parameter. To perform transformation, see :doc:`vsgi/converters` and
    :doc:`middlewares/index`.

The handler takes a callback as an optional third argument. This callback is
a continuation that will continue the routing process to the next matching
route.

::

    app.get ("/", (req, res, next) => {
        return next (); // keep routing
    });

    app.get ("/", (req, res) => {
        // this is invoked!
    });

Error handling
--------------

.. versionadded:: 0.2.1

    Prior to this release, any unhandled error would crash the main loop
    iteration.

.. versionchanged:: 0.3

    Error and status codes are now handled with a ``catch`` block or using the
    :doc:`middlewares/status` middleware.

.. versionchanged:: 0.3

    The default handling is not ensured by the :doc:`middlewares/basic`
    middleware.

The router will capture any thrown `GLib.Error`_ and produce an internal error
accordingly.

Similarly to status codes, errors are propagated in the ``HandlerCallback`` and
``NextCallback`` delegate signatures and can be handled in a ``catch`` block.

::

    app.use (() => {
        try {
            return next ();
        } catch (IOError err) {
            res.status = 500;
            return res.expand_utf8 (err.message);
        }
    });

    app.get ("/", (req, res) => {
        throw new IOError.FAILED ("I/O failed some some reason.");
    });

.. _GLib.Error: http://valadoc.org/#!api=glib-2.0/GLib.Error

Thrown status code can also be caught this way, but it's much more convenient
to use the :doc:`middlewares/status` middleware.

Sequence
--------

.. versionadded:: 0.2

``Route`` has a ``then`` function that can be used to produce to sequence
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

One common pattern with subrouting is to attempt another router and fallback on
``next``.

::

    var app = new Router ();
    var api = new Router ();

    app.get ("/some-resource", (req, res) => {
        return api.handle (req, res) || next ();
    });

.. _cleaning-up-route-logic:

Cleaning up route logic
-----------------------

Performing a lot of route bindings can get messy, particularly if you want to
split an application several reusable modules. Encapsulation can be achieved by
subclassing ``Router`` and performing initialization in a ``construct`` block:

::

    public class AdminRouter : Router {

        construct {
            rule (Method.GET,               "/admin/user",          view);
            rule (Method.GET | Method.POST, "/admin/user/<int:id>", edit);
        }

        public bool view (Request req, Response res) {
            return render_template ("users", Users.all ());
        }

        public bool edit (Request req, Response res) {
            var user = User.find (ctx["id"]);
            if (req.method == "POST") {
                user.values (Soup.Form.decode (req.flatten_utf8 ()));
                user.update ();
            }
            return render_template ("user", user);
        }
    }

Using subrouting, it can be assembled to a parent router given a rule (or any
matching process described in this document). This way, incoming request having
the ``/admin/`` path prefix will be delegated to the ``admin`` router.

::

    var app = new Router ();

    app.rule (Method.ALL, "/admin/*", new AdminRouter ().handle);

The :doc:`middlewares/basepath` middleware provide very handy path isolation so
that the router can be simply written upon the leading ``/`` and rebased on any
basepath. In that case, we can strip the leading ``/admin`` in router's rules.

::

    var app = new Router ();

    // captures '/admin/users' and '/admin/user/<int:id>'
    app.use (basepath ("/admin", new AdminRouter ().handle));

