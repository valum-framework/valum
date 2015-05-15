Route
=====

Route is a structure that pairs a matcher and a handler.

-  the matcher tells if the Route accepts the given request and populate
   its parameters
-  the handler processes the `Request <vsgi/request.md>`__ and produce a
   `Response <vsgi/response.md>`__

Matching using a rule
---------------------

Rules are used by the HTTP methods alias and ``method`` function in
`Router <router.md>`__.

.. code:: vala

    // using an alias
    app.get ("your-rule/<int:id>", (req, res) => {

    });

    // using a method
    app.method (Request.GET, "your-rule/<int:id>", (req, res) => {

    });

Rule syntax
~~~~~~~~~~~

This class implements the rule system designed to simplify regular
expression.

The following are rules examples:

-  ``/user``
-  ``/user/<id>``
-  ``/user/<int:id>``

In this example, we call ``id`` a parameter and ``int`` a type. These
two definitions will be important for the rest of the document.

These will respectively compile down to the following regular
expressions

-  ``^/user$``
-  ``^/user/(?<id>\w+)$``
-  ``^/user/(?<id>\d+)$``

Types
~~~~~

Valum provides the following built-in types

-  int that matches ``\d+``
-  string that matches ``\w+`` (this one is implicit)
-  path that matches ``[\w/]+``
-  any that matches ``.+``

Undeclared type is assumed to be ``string``, this is what implicit
meant.

The ``int`` type is useful for matching non-negative identifier such as
database primary key.

the ``path`` type is useful for matching pieces of route including
slashes. You can use this one to serve a folders hierachy.

The ``any`` type is useful to create catch-all route. The sample
application shows an example for creating a 404 error page.

.. code:: vala

    app.get("<any:path>", (req, res) => {
        res.status = 404;
    });

It is possible to specify new types using the ``types`` map in
``Router``. This example will define the ``path`` type matching words
and slashes using a regular expression literal.

.. code:: vala

    app.types["path"] = /[\\w\/]+/;

Types are defined at construct time of the ``Router`` class. It is
possible to overwrite the built-in type.

If you would like ``ìnt`` to match negatives integer, you may just do:

.. code:: vala

    app = new Router ();

    app.types["int"] = /-?\d+/;

Matching using a regular expression
-----------------------------------

If the rule system does not suit your needs, it is always possible to
use regular expression. Regular expression will be automatically scoped,
anchored and optimized.

.. code:: vala

    app.regex (Request.GET, /home\/?/, (req, res) => {
        var writer = new DataOutputStream (res);
        writer.put_string ("Matched using a regular expression.");
    });

Matching using a low-level matcher
----------------------------------

In some scenario, you need more than a just matching the request path
using a regular expression. Internally, Route uses a matcher pattern and
it is possible to define them yourself.

A matcher consist of a callback matching a given ``Request`` object.

.. code:: vala

    Route.Matcher matcher = (req) => { req.path == "/custom-matcher"; };

    app.matcher ("GET", matcher, (req, res) => {
        var writer = new DataOutputStream (res);
        writer.put_string ("Matched using a custom matcher.");
    });

You could, for instance, match the request if the user is an
administrator and fallback to a default route otherwise.

.. code:: vala

    app.matcher ("GET", (req) => {
        var user = new User (req.query["id"]);
        return "admin" in user.roles;
    }, (req, res) => {});

    app.route ("<any:path>", (req, res) => {
        res.status = 404;
    });

Combining custom matcher with existing matcher
----------------------------------------------

If all you want is to do some processing and fallback on a Regex or rule
matching, you can combine instanciate directly a Route.

Matcher should respect the *populate if match* principle, so design it
in a way that the request parameters remain untouched if the matcher
happens not to accept the request.

.. code:: vala

    app.matcher ("GET", (req) => {
        var route = new Route.from_rule (app, "your-rule");

        // database access only if the rule is respected
        var user = new User (req.query["id"]);
        return "admin" in user.roles && route.match (req);
    });
