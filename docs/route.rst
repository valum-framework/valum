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

Matching using a rule
~~~~~~~~~~~~~~~~~~~~~

Rules are used by the HTTP methods alias (``get``, ``post``, ...) and
``method`` function in :doc:`router`.

::

    // using an alias
    app.get ("your-rule/<int:id>", (req, res) => {

    });

    // using a method
    app.method (Request.GET, "your-rule/<int:id>", (req, res) => {

    });

Rule syntax
~~~~~~~~~~~

This class implements the rule system designed to simplify regular expression.

A rule is a simple path with parameters delimited with ``<`` and ``>``
characters. Formally, a parameter is defined by the following EBNF:

.. code-block:: ebnf

    parameter = '<', [ type, ':' ], name, '>';
    type      = word, { word_or_number };
    name      = word, { word_or_number };
    word      = ? any word character ?;

The following items are valid rules:

-  ``/user``
-  ``/user/<id>``
-  ``/user/<int:id>``

They will respectively compile down to the following regular expressions. Note
that rules are matching the whole path as they are automatically anchored and
the leading ``/`` must be omitted.

-  ``^/user$``
-  ``^/user/(?<id>\w+)$``
-  ``^/user/(?<id>\d+)$``

Null rule
~~~~~~~~~

The ``null`` rule can be used to match all possible request paths. It can be
used to perform setup operations.

The matched path will be made available in the ``path`` parameter.

::

    app.get (null, (req, res, next) => {
        // always invoked!

        var path = req.params["path"]; // matched path

        next (req, res);
    });

    app.get ("", (req, res) => {
        res.write_all ("Hello world!".data, null);
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

::

    app.get("<any:path>", (req, res) => {
        res.status = 404;
    });

It is possible to specify or overwrite types using the ``types`` map in
:doc:`router`. This example will define the ``path`` type matching words and
slashes using a regular expression literal.

::

    app.types["path"] = new Regex ("[\w/]+", RegexCompileFlags.OPTIMIZE);

If you would like ``ìnt`` to match negatives integer, you may just do:

::

    var app = new Router ();

    app.types["int"] = new Regex ("-?\d+", RegexCompileFlags.OPTIMIZE);

Rule parameters are available from the routing context by their name.

::

    app.get ("<controller>/<action>", (req, res, next, context) => {
        var controller = context["controller"].get_string ();
        var action     = context["action"].get_string ();
    });

Matching using a regular expression
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If the rule system does not suit your needs, it is always possible to use
regular expression. Regular expression will be automatically scoped, anchored
and optimized.

::

    app.regex (Request.GET, new Regex ("home/?", RegexCompileFlags.OPTIMIZE), (req, res) => {
        var writer = new DataOutputStream (res.body);
        writer.put_string ("Matched using a regular expression.");
    });

Named captures are registered in the routing context.

::

    app.regex (new Regex ("(?<word>\w+)", RegexCompileFlags.OPTIMIZE), (req, res, next, context) => {
        var word = context["word"].get_string ();
    });

Matching using a callback
~~~~~~~~~~~~~~~~~~~~~~~~~

In some scenario, you need more than a just matching the request path using
a regular expression. Internally, Route uses a matcher pattern and it is
possible to define them yourself.

A matcher consist of a callback matching a given ``Request`` object.

::

    MatcherCallback matcher = (req) => { req.path == "/custom-matcher"; };

    app.matcher ("GET", matcher, (req, res) => {
        var writer = new DataOutputStream (res.body);
        writer.put_string ("Matched using a custom matcher.");
    });

You could, for instance, match the request if the user is an administrator and
fallback to a default route otherwise.

::

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

::

    app.matcher ("GET", (req) => {
        var route = new Route.from_rule (app, "your-rule");

        // database access only if the rule is respected
        var user = new User (req.query["id"]);
        return "admin" in user.roles && route.match (req);
    });

Handler
-------

Handler process a pair of :doc:`vsgi/request` and :doc:`vsgi/response` and can
throw various status code during the processing to handle cases that breaks the
code flow conveniently. They are fully covered in the :doc:`router` document.

See :doc:`redirection-and-error` for more details on what can be throws during
the processing of a handler.

::

    app.get ("redirection", (req, res) => {
        throw new Redirection.MOVED_TEMPORAIRLY ("http://example.com");
    });
