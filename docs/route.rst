Route
=====

Route is a structure that pairs a matcher and a handler.

-  the matcher tells if the Route accepts the given request and populate
   its parameters
-  the handler processes the :doc:`vsgi/request` and produce a :doc:`vsgi/response`.

Matcher
-------

Request parameters
~~~~~~~~~~~~~~~~~~

It is important to keep in mind that the request parameters result from
a side-effect. If a matcher accept the request, it may populate the parameters.
The matching process in :doc:`router` guarantees that only one matcher can
accept the request and thus populate the parameters.

Request can be parametrized in a general manner:

-  extract data from the URI path like an integer identifier
-  extract data from the headers such as the request refeerer

:doc:`../route` created from a rule or a regular expression will populate the
parameters with their named captures.

.. code:: vala

    app.get ("<int:i>", (req, res) => {
        var i = req.params["i"];
    });

Parameters default to ``null`` if it is not populated by any matchers.

Matching using a rule
~~~~~~~~~~~~~~~~~~~~~

Rules are used by the HTTP methods alias and ``method`` function in
:doc:`router`.

.. code:: vala

    // using an alias
    app.get ("your-rule/<int:id>", (req, res) => {

    });

    // using a method
    app.method (Request.GET, "your-rule/<int:id>", (req, res) => {

    });

Rule syntax
~~~~~~~~~~~

This class implements the rule system designed to simplify regular expression.

The following are rules examples:

-  ``/user``
-  ``/user/<id>``
-  ``/user/<int:id>``

In this example, we call ``id`` a parameter and ``int`` a type. These wo
definitions will be important for the rest of the document.

These will respectively compile down to the following regular expressions

-  ``^/user$``
-  ``^/user/(?<id>\w+)$``
-  ``^/user/(?<id>\d+)$``

Null rule
~~~~~~~~~

The ``null`` rule can be used to match all possible request paths. It can be
used to perform setup operations.

.. code:: vala

    app.get (null, (req, res, next) => {
        // always invoked!
    });

    app.get ("", (req, res) => {
        //
    });

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

the ``path`` type is useful for matching pieces of route including slashes. You
can use this one to serve a folders hierachy.

The ``any`` type is useful to create catch-all route. The sample application
shows an example for creating a 404 error page.

.. code:: vala

    app.get("<any:path>", (req, res) => {
        res.status = 404;
    });

It is possible to specify new types using the ``types`` map in ``Router``. This
example will define the ``path`` type matching words and slashes using
a regular expression literal.

.. code:: vala

    app.types["path"] = /[\\w\/]+/;

Types are defined at construct time of the ``Router`` class. It is possible to
overwrite the built-in type.

If you would like ``ìnt`` to match negatives integer, you may just do:

.. code:: vala

    app = new Router ();

    app.types["int"] = /-?\d+/;

Matching using a regular expression
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If the rule system does not suit your needs, it is always possible to use
regular expression. Regular expression will be automatically scoped, anchored
and optimized.

.. code:: vala

    app.regex (Request.GET, /home\/?/, (req, res) => {
        var writer = new DataOutputStream (res);
        writer.put_string ("Matched using a regular expression.");
    });

Matching using a callback
~~~~~~~~~~~~~~~~~~~~~~~~~

In some scenario, you need more than a just matching the request path using
a regular expression. Internally, Route uses a matcher pattern and it is
possible to define them yourself.

A matcher consist of a callback matching a given ``Request`` object.

.. code:: vala

    Route.MatcherCallback matcher = (req) => { req.path == "/custom-matcher"; };

    app.matcher ("GET", matcher, (req, res) => {
        var writer = new DataOutputStream (res);
        writer.put_string ("Matched using a custom matcher.");
    });

You could, for instance, match the request if the user is an administrator and
fallback to a default route otherwise.

.. code:: vala

    app.matcher ("GET", (req) => {
        var user = new User (req.query["id"]);
        return "admin" in user.roles;
    }, (req, res) => {});

    app.route ("<any:path>", (req, res) => {
        res.status = 404;
    });

Combining custom matcher with existing matcher
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If all you want is to do some processing and fallback on a Regex or rule
matching, you can combine instanciate directly a Route.

Matcher should respect the *populate if match* principle, so design it in a way
that the request parameters remain untouched if the matcher happens not to
accept the request.

.. code:: vala

    app.matcher ("GET", (req) => {
        var route = new Route.from_rule (app, "your-rule");

        // database access only if the rule is respected
        var user = new User (req.query["id"]);
        return "admin" in user.roles && route.match (req);
    });

Handler
-------

Handler process a a pair of :doc:`vsgi/request` and :doc:`vsgi/response` and
can throw various status code during the processing to handle cases that breaks
the code flow conveniently.

The definition of a handler is the following:

.. code:: vala

    delegate void HandlerCallback (Request req, Response res, NextCallback) throws Redirection, ClientError, ServerError;

See :doc:`redirection-and-error` for more details on what can be throws during
the processing of a handler.

.. code:: vala

    app.get ("redirection", (req, res) => {
        throw new Redirection.MOVED_TEMPORAIRLY ("http://example.com");
    });
