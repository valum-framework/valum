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

Handling a ``POST`` request would be something like

.. code:: vala

    app.post ("login", (req, res) => {
		var writer = new DataOutputStream (res);
		var buffer = new MemoryOutputStream (null, realloc, free);

        # consume the body
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

Setup and teardown signals
--------------------------

Valum's Router define ``setup`` and ``teardown`` signals which are called
before and after a request processing.

.. code:: vala

    app.setup.connect ((req, res) => {
        // called before a request is being processed
    });

The default handler of the ``setup`` signal will initialize the response object
with some sane defaults:

-  200 status code
-  ``text/html`` content type
-  request cookies

If you want to override any of the defaults, you must bind a callback with
``connect_after`` as it will be executed after the default handler.

.. code:: vala

    app.setup.connect_after ((req, res) => {
        res.status = Soup.Status.NOT_FOUND;
    });

The ``teardown`` signal is executed in a finally clause, which means that it
will be triggered even if an error is thrown in the matched route handler.

.. code:: vala

    app.teardown.connect ((req, res) => {
        // called after a request has been processed
    })

It might not be possible to write in the response body in the ``teardown``, so
you must check if it is closed.

.. code:: vala

    app.teardown.connect ((req, res) => {
        if (!res.is_closed)
            res.write ("I can still write!".data);
    })
