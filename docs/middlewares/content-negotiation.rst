Content Negotiation
===================

Negotiating the resource representation is an essential part of the HTTP
protocol.

The negotiation process is simple: expectations are provided for a specific
header, if they are met, the processing is forwarded with the highest quality
value, otherwise a ``406 Not Acceptable`` status is raised.

.. code:: vala

    using Valum.ContentNegotiation;

    app.get ("", negotiate ("Accept",
                             "text/html, text/html+xml",
                            (req, res, next, stack, content_type) => {
        // produce a response based on 'content_type'
    }));

Pass the ``NegotiateFlags.NEXT`` flag to forward with ``next`` instead of
raising a ``406 Not Acceptable``.

.. code:: vala

    app.get ("", negotiate ("Accept", "text/html", (req, res) => {
        // produce 'text/html'
    }, NegotiateFlags.NEXT)).then ((req, res) => {
        // the user agent does not accept 'text/html'
    });

The default value for the continuation is ``forward``. It will simply call
``next`` to continue to the next middleware following the negotiation. This is
typically what would be found on the top of an application.

.. code:: vala

    app.use (negotiate ("Accept", "text/xhtml"));

    // all the following route assume that 'text/xhtml' is being produced.

    app.status (Soup.Status.NOT_ACCEPTABLE, (req, res) => {
        // handle '406 Not Acceptable' here
    });

A custom comparison function can be provided to ``negotiate`` in order to
handle wildcards and other edge cases. The user agent pattern is the first
argument and the expectation is the second.

.. warning::

    Most of the HTTP/1.1 specification about headers is case-insensitive, use
    `Soup.str_case_equal`_ to perform comparisons.

.. _Soup.str_case_equal: http://valadoc.org/#!api=libsoup-2.4/Soup.str_case_equal

.. code:: vala

    app.use (negotiate ("Accept",
                        "text/xhtml",
                        forward,
                        NegotiateFlags.NONE,
                        (a, b) => {
        return a == "*" || Soup.str_case_equal (a, b);
    });

Middlewares
-----------

For convenience, middlewares that support edge cases are provided to handle
common headers:

+---------------------+----------------------+------------------------+
| Middleware          | Header               | Edge cases             |
+=====================+======================+========================+
| ``accept``          | ``Content-Type``     | ``*/*`` and ``type/*`` |
+---------------------+----------------------+------------------------+
| ``accept_charset``  | ``Content-Type``     | ``*``                  |
+---------------------+----------------------+------------------------+
| ``accept_encoding`` | ``Content-Encoding`` | ``*``                  |
+---------------------+----------------------+------------------------+
| ``accept_language`` | ``Content-Language`` | missing language type  |
+---------------------+----------------------+------------------------+
| ``accept_ranges``   | ``Content-Ranges``   | none                   |
+---------------------+----------------------+------------------------+

The ``accept`` middleware will assign the media type and preserve all other
parameters.

The ``accept_encoding`` middleware will convert the :doc:`../vsgi/response` if
it's either ``gzip`` or ``deflate``.

.. warning::

    The ``accept_encoding`` middleware must always be applied before
    ``accept_charset`` to avoid corruption; converting the charset of
    a compressed binary format is not an excellent idea.
