Route
=====

Route is a structure that pairs a matcher and a handler.

-  the matcher tells if the Route accepts the given request and populate
   its parameters
-  the handler processes the :doc:`vsgi/request` and produce a :doc:`vsgi/response`.

There are three ways of matching user requests:

-  using the rule system
-  with a regular expression on the request path
-  with a matching callback

Matching using a rule
---------------------

Rules are used by the HTTP methods alias (``get``, ``post``, ...) and ``rule``
functions in :doc:`router`.

::

    // using an alias
    app.get ("your-rule/<int:id>", (req, res) => {

    });

    // using a method
    app.rule (Request.GET, "your-rule/<int:id>", (req, res) => {

    });

Rule syntax
~~~~~~~~~~~

The ``RuleRoute`` class implements the rule system designed to simplify regular
expression.

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

The :doc:`router` handles leading slash implicitly, so they must be omitted.

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
-----------------------------------

If the rule system does not suit your needs, it is always possible to use
regular expression. Regular expression will be automatically scoped, anchored
and optimized.

::

    app.regex (Request.GET, new Regex ("home/?", RegexCompileFlags.OPTIMIZE), (req, res) => {
        return res.body.write_all ("Matched using a regular expression.".data, true);
    });

Named captures are registered in the routing context.

::

    app.regex (new Regex ("(?<word>\w+)", RegexCompileFlags.OPTIMIZE), (req, res, next, ctx) => {
        var word = ctx["word"].get_string ();
    });

Matching using a callback
-------------------------

In some scenario, you need more than a just matching the request path using
a regular expression. Internally, Route uses a matcher pattern and it is
possible to define them yourself.

A matcher consist of a callback matching a given ``Request`` object.

::

    MatcherCallback matcher = (req) => { req.path == "/custom-matcher"; };

    app.matcher (Method.GET, matcher, (req, res) => {
        return res.body.write_all ("Matched using a custom matcher.".data, null);
    });

You could, for instance, match the request if the user is an administrator and
fallback to a default route otherwise.

::

    app.matcher (Method.GET, (req) => {
        var user = new User (req.query["id"]);
        return "admin" in user.roles;
    }, (req, res) => {
        // ...
    });

    app.use ((req, res) => {
        res.status = 404;
    });

Combining custom matcher with existing matcher
----------------------------------------------

If all you want is to do some processing and fallback on a Regex or rule
matching, you can combine instanciate directly a Route.

Matcher should respect the *populate if match* principle, so design it in a way
that the request parameters remain untouched if the matcher happens not to
accept the request.

::

    app.matcher (Method.GET, (req) => {
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
