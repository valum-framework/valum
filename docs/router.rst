Router
======

Router is the core component of Valum. It dispatches request to the right
handler and processes certain error conditions described in
:doc:`redirection-and-error`.

HTTP methods
------------

Callback can be connected to HTTP methods via a list of helpers having the
``Route.Handler`` delegate signature:

.. code:: vala

    app.get ("rule", (req, res) => {});

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

.. code:: vala

    app.post ("login", (req, res) => {
        var buffer = new MemoryOutputStream (null, realloc, free);

        // consume the request body
        buffer.splice (req, OutputStreamSpliceFlags.CLOSE_SOURCE);

        var data = Soup.Form.decode ((string) buffer.get_data ());

        var username = data["username"];
        var password = data["password"];

        // assuming you have a session implementation in your app
        var session = new Session.authenticated_by (username, password);
    });

It is also possible to use a custom HTTP method via the ``method``
function.

.. code:: vala

    app.method ("METHOD", "rule", (req, res) => {});

:doc:`vsgi/request` provide an enumeration of HTTP methods for your
convenience.

.. code:: vala

    app.method (Request.GET, "rule", (req, res) => {});

Capture of multiple methods for the same handler is planned for the next minor
release.

Regular expression
------------------

.. code:: vala

    app.regex (/home/, (req, res) => {
        // matches /home
    });

Matcher callback
----------------

Request can be matched by a simple callback, but you have to be cautious if you
want to fill request parameters. You must respect the `populate if match` rule,
otherwise you will experience inconsistencies.

.. code:: vala

    app.matcher (Request.GET, (req) => { return req.uri.get_path () == "/home"; }, (req, res) => {
        // matches /home
    });

Scoping
-------

Scoping is a powerful prefixing mechanism for rules and regular expressions.
Route declarations within a scope will be prefixed by ``<scope>/``. There is an
implicit initial scope so that all rules are automatically rooted with (``/``).

The ``Router`` maintains a scope stack so that when the program flow enter
a scope, it pushes the fragment on top of that stack and pops it when it exits.

The default separator is a ``/`` and it might become possible to change it in
a future release.

.. code:: vala

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

Since ``VSGI.Application`` handler is type compatible with ``Route.Handler``,
it is possible to delegate request handling to another VSGI-compliant
application.

.. code:: vala

    var app = new Router ();
    var api = new Router ();

    // delegate all GET requests to api router
    app.get ("<any:any>", api.handle);

This feature can be used to combine independently working applications in
a single one, as opposed to :doc:`module`, which are designed to be
specifically integrated in a working application.

It is important to be cautious since the pair of request-response may be the
target of side-effects such as:

-  parent router ``setup`` and ``teardown`` signals can operate before and
   after the delegated handler
-  matcher that matched the request before being delegated may initialize the
   :doc:`vsgi/request` parameters

In the example, the ``<any:any>`` parameter will initialize the
:doc:`vsgi/request` parameters.

Next
----

The :doc:`route` handler takes a callback as an optional third argument. This
callback is a continuation that will continue the routing process to the next
matching route.

.. code:: vala

    app.get ("", (req, res, next) => {
        message ("pre");
        next (); // keep routing
    });

    app.get ("", (req, res) => {
        // this is invoked!
    });
