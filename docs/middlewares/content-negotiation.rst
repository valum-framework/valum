Content Negotiation
===================

Negotiating the resource representation is an essential part of the HTTP
protocol.

The negotiation process is simple: expectations are provided for a specific
header, if they are met, the processing is forwarded with the highest quality
value, otherwise a ``406 Not Acceptable`` status is raised.

.. code:: vala

    using Valum.ContentNegotiation;

    app.get ("/", negotiate ("Accept", "text/html, text/html+xml",
                            (req, res, next, stack, content_type) => {
        // produce a response based on 'content_type'
    }));

Typically, one would simply call ``next`` to continue to the next middleware
following the negotiation and handle possible error upstream.

.. code:: vala

    app.use (status (Soup.Status.NOT_ACCEPTABLE, () => {
        // handle '406 Not Acceptable' here
    }));

    app.use (negotiate ("Accept", "text/xhtml", () => {
        return next ();
    }));

    // all the following route assume that 'text/xhtml' is being produced.

Custom comparison
-----------------

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
                        () => { return true; },
                        (a, b) => {
        return a == "*" || Soup.str_case_equal (a, b);
    });

Helpers
-------

For convenience, helpers are provided to handle common headers:

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

The ``accept_charset`` middleware will set the ``charset`` parameter of the
``Content-Type`` header, defaulting to ``application/octet-stream`` if
undefined.

