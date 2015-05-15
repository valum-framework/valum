Request
=======

Represents an incoming request to your application to which you have to
provide a `response <vsgi/response>`__.

This is part of VSGI, a middleware upon which Valum is built.

HTTP method
-----------

The Request class provides constants for the following HTTP methods:

-  ``OPTIONS``
-  ``GET``
-  ``HEAD``
-  ``POST``
-  ``PUT``
-  ``DELETE``
-  ``TRACE``
-  ``CONNECT``
-  ``PATCH``

Additionnaly, an array of HTTP methods ``Request.METHODS`` is providen
to list all supported HTTP methods by VSGI.

These can be conveniently used in low-level ``Router`` functions to
avoid using plain strings to describe standard HTTP methods.

.. code:: vala

    app.method (Request.GET, "", (req, res) => {
        // ...
    });

Request parameters
------------------

Request parameters are metadata extracted by the ``Route.Matcher`` that
matched the request you are handling. They can contain pretty much
anything since a matcher can be any function accepting a ``Request``
instance.

It is important to keep in mind that the request parameters result from
a side-effect. If a matcher accept the request, it may populate the
parameters. The matching process in ``Router`` guarantees that only one
matcher can accept the request and thus populate the parameters.

Request can be parametrized in a general manner

-  extract data from the URI path like an integer identifier
-  extract data from the headers such as the request refeerer

The request parameters are stored in a ``HashTable<string, string>`` and
can be accessed from the ``Request.params`` property.

You can compose your own matcher to do any kind of processing, as long
as you respect the *populate if match* rule.

.. code:: vala

    app.matcher((req) => {
        if (/* matching conditions */) {
            req.params = new HashMap<string, string> ();

            req.params["a"] = "b";

            return true;
        }
        return false;
    }, (req, res) => {
        // heavy computation...
        res.write("Hello world!".data);
    });

``Route`` created from a `rule <route#rules>`__ or a `regular
expression <route#plubbering-with-regular-expression>`__ will populate
the parameters with their named captures.

.. code:: vala

    app.get ("<int:i>", (req, res) => {
        var i = req.params["i"];
    });

Parameters default to ``null`` if it is not populated by any matchers.

.. code:: vala

    app.get ("", (req, res) => {
        // req.params == null
    });
