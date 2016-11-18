Content Negotiation
===================

Negotiating the resource representation is an essential part of the HTTP
protocol.

The negotiation process is simple: expectations are provided for a specific
header, if they are met, the processing is forwarded with the highest quality
value, otherwise a ``406 Not Acceptable`` status is raised.

::

    using Valum.ContentNegotiation;

    app.get ("/", negotiate ("Accept", "text/html, text/html+xml",
                            (req, res, next, stack, content_type) => {
        // produce a response based on 'content_type'
    }));

Or directly by using the default forward callback:

::

    app.use (negotiate ("Accept", "text/html"));

    // all route declaration may assume that the user agent accept 'text/html'

Preference and quality
----------------------

Additionally, the server can state the quality of each expectation. The
middleware will maximize the product of quality and user agent preference with
respect to the order of declaration and user agent preferences if it happens to
be equal.

If, for instance, you would serve a XML document that is just poorly converted
from a JSON source, you could state it by giving it a low ``q`` value. If the
user agent as a strong preference the former and a low preference for the
latter (eg. ``Accept: text/xml; application/json; q=0.1)``), it will be served
the version with the highest product (eg. ``0.3 * 1 > 1 * 0.3``).

::

    app.get ("/", negotiate ("Accept", "application/json;, text/xml; q=0.3",
                            (req, res, next, stack, content_type) => {
        // produce a response based on 'content_type'
    }));

Error handling
--------------

The :doc:`status` middleware may be used to handle the possible ``406 Not Acceptable``
error raised if no expectation can be satisfied.

::

    app.use (status (Soup.Status.NOT_ACCEPTABLE, () => {
        // handle '406 Not Acceptable' here
    }));

    app.use (negotiate ("Accept", "text/xhtml; text/html", () => {
        // produce appropriate resource
    }));

Custom comparison
-----------------

A custom comparison function can be provided to :valadoc:`valum-0.3/Valum.negotiate`
in order to handle wildcards and other edge cases. The user agent pattern is
the first argument and the expectation is the second.

.. warning::

    Most of the HTTP/1.1 specification about headers is case-insensitive, use
    :valadoc:`libsoup-2.4/Soup.str_case_equal` to perform comparisons.

::

    app.use (negotiate ("Accept",
                        "text/xhtml",
                        () => { return true; },
                        (a, b) => {
        return a == "*" || Soup.str_case_equal (a, b);
    });

Helpers
-------

For convenience, helpers are provided to handle common headers:

+---------------------+----------------------+----------------------------------------------------+
| Middleware          | Header               | Edge cases                                         |
+=====================+======================+====================================================+
| ``accept``          | ``Content-Type``     | ``*/*``, ``type/*`` and ``type/subtype1+subtype2`` |
+---------------------+----------------------+----------------------------------------------------+
| ``accept_charset``  | ``Content-Type``     | ``*``                                              |
+---------------------+----------------------+----------------------------------------------------+
| ``accept_encoding`` | ``Content-Encoding`` | ``*``                                              |
+---------------------+----------------------+----------------------------------------------------+
| ``accept_language`` | ``Content-Language`` | missing language type                              |
+---------------------+----------------------+----------------------------------------------------+
| ``accept_ranges``   | ``Content-Ranges``   | none                                               |
+---------------------+----------------------+----------------------------------------------------+

The :valadoc:`valum-0.3/Valum.accept` middleware will assign the media type and
preserve all other parameters.

If multiple subtypes are specified (e.g. ``application/vnd.api+json``), the
middleware will check if the subtypes accepted by the user agent form a subset.
This is useful if you serve a specified JSON document format to a client which
only state to accept JSON and does not care about the specification itself.

::

    accept ("text/html; text/xhtml", (req, res, next, ctx, content_type) => {
        switch (content_type) {
            case "text/html":
                return produce_html ();
            case "text/xhtml":
                return produce_xhtml ();
        }
    });

The :valadoc:`valum-0.3/Valum.accept_encoding` middleware will convert the
:doc:`../vsgi/response` if it's either ``gzip`` or ``deflate``.

::

    accept ("gzip; deflate", (req, res, next, ctx, encoding) => {
        res.expand_utf8 ("Hello world! (compressed with %s)".printf (encoding));
    });

The :valadoc:`valum-0.3/Valum.accept_charset` middleware will set the
``charset`` parameter of the ``Content-Type`` header, defaulting to
``application/octet-stream`` if undefined.

