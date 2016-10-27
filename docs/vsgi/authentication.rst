HTTP authentication
===================

VSGI provide implementations of both basic and digest authentication schemes
respectively defined in `RFC 7617`_ and `RFC 7616`_.

.. _RFC 7617: https://tools.ietf.org/html/rfc7617
.. _RFC 7616: https://tools.ietf.org/html/rfc7616

Both ``Authentication`` and ``Authorization`` objects are provided to produce
and interpret their corresponding HTTP headers. The typical authentication
pattern is highlighted in the following example:

::

    var authentication = BasicAuthentication ("realm");

    var authorization_header = req.headers.get_one ("Authorization");

    if (authorization_header != null) {
        if (authentication.parse_authorization_header (authorization_header,
                                                       out authorization)) {
            var user = User.from_username (authorization.username);
            if (authorization.challenge (user.password)) {
                return res.expand_utf8 ("Authentication successful!");
            }
        }
    }

    res.headers.replace ("WWW-Authenticate", authentication.to_authenticate_header ());

Basic
-----

The ``Basic`` authentication scheme is the simplest one and expect the user
agent to provide username and password in plain text. It should be used
exclusively on a secured transport (e.g. HTTPS).

