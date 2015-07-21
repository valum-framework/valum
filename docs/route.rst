Route
=====

Route is a structure that pairs a matcher and a handler.

-  the matcher tells if the Route accepts the given request and populate
   its parameters
-  the handler processes the :doc:`vsgi/request` and produce a :doc:`vsgi/response`.

Matcher
-------

There are three ways of matching user requests:

-  using the rule system
-  with a regular expression on the request path
-  with a matching callback

Once matched, the :doc:`vsgi/request` parameters might be populated to provide
additional information about the request.

Request parameters
~~~~~~~~~~~~~~~~~~

.. deprecated:: 0.2
    Request parameters are stored in the stack.

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

Request parameters (stacked)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Request parameters are accumulated in the routing stack in their conventional
order and can be popped in a handler in the reverse order.

.. code:: vala

    app.get ("<controller><action>", (req, res, next, stack) => {
        var action     = stack.pop_tail ();
        var controller = stack.pop_tail ();
    });

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

The matched path will be made available in the ``path`` parameter.

.. code:: vala

    app.get (null, (req, res, next) => {
        // always invoked!

        var path = req.params["path"]; // matched path

        next ();
    });

    app.get ("", (req, res) => {
        res.write ("Hello world!".data);
    });


Scope
~~~~~

Rules and regular expressions are scoped by prefixing the scope stack from the
:doc:`router` in the generated regular expression.

Types
~~~~~

Valum provides built-in types initialized in the :doc:`router` constructor. The
following table details these types and what they match.

+------------+------------+-----------------------------------------------+
| Type       | Regex      | Description                                   |
+============+============+===============================================+
| ``int``    | ``\d+``    | matches non-negative integers like a database |
|            |            | primary key                                   |
+------------+------------+-----------------------------------------------+
| ``string`` | ``\w+``    | matches any word character                    |
+------------+------------+-----------------------------------------------+
| ``path``   | ``[\w/]+`` | matches a piece of route including slashes    |
+------------+------------+-----------------------------------------------+
| ``any``    | ``.+``     | matches anything                              |
+------------+------------+-----------------------------------------------+

Undeclared types default to ``string``, which matches any word characters.

.. code:: vala

    app.get("<any:path>", (req, res) => {
        res.status = 404;
    });

It is possible to specify or overwrite types using the ``types`` map in
:doc:`router`. This example will define the ``path`` type matching words and
slashes using a regular expression literal.

.. code:: vala

    app.types["path"] = /[\\w\/]+/;

If you would like ``ìnt`` to match negatives integer, you may just do:

.. code:: vala

    var app = new Router ();

    app.types["int"] = /-?\d+/;

Matching using a regular expression
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If the rule system does not suit your needs, it is always possible to use
regular expression. Regular expression will be automatically scoped, anchored
and optimized.

.. code:: vala

    app.regex (Request.GET, /home\/?/, (req, res) => {
        var writer = new DataOutputStream (res.body);
        writer.put_string ("Matched using a regular expression.");
    });

Matching using a callback
~~~~~~~~~~~~~~~~~~~~~~~~~

In some scenario, you need more than a just matching the request path using
a regular expression. Internally, Route uses a matcher pattern and it is
possible to define them yourself.

A matcher consist of a callback matching a given ``Request`` object.

.. code:: vala

    MatcherCallback matcher = (req) => { req.path == "/custom-matcher"; };

    app.matcher ("GET", matcher, (req, res) => {
        var writer = new DataOutputStream (res.body);
        writer.put_string ("Matched using a custom matcher.");
    });

You could, for instance, match the request if the user is an administrator and
fallback to a default route otherwise.

.. code:: vala

    app.matcher ("GET", (req) => {
        var user = new User (req.query["id"]);
        return "admin" in user.roles;
    }, (req, res) => {
        // ...
    });

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

See :doc:`redirection-and-error` for more details on what can be throws during
the processing of a handler.

.. code:: vala

    app.get ("redirection", (req, res) => {
        throw new Redirection.MOVED_TEMPORAIRLY ("http://example.com");
    });
