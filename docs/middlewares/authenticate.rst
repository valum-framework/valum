Authenticate
============

The :valadoc:`valum-0.3/Valum.authenticate` middleware allow one to perform
HTTP basic authentications.

It takes three parameters:

-   an :valadoc:`vsgi-0.3/VSGI.Authentication` object described in :doc:`../vsgi/authentication`
-   a callback to challenge a user-provided :valadoc:`vsgi-0.3/VSGI.Authorization` header
-   a forward callback invoked on success with the corresponding authorization
    object

If the authentication fails, a ``401 Unauthorized`` status is raised with
a ``WWW-Authenticate`` header.

::

    app.use (authenticate (new BasicAuthentication ("realm")), (authorization) => {
        return authorization.challenge ("some password");
    }, (req, res, next, ctx, username) => {
        return res.expand_utf8 ("Hello %s".printf (username));
    });

To perform custom password comparison, it is best to cast the ``authorization``
parameter and access the password directly.

::

    public bool authenticate_user (string username, string password) {
        // authenticate the user against the database...
    }

    app.use (authenticate (new BasicAuthentication ("realm")), (authorization) => {
        var basic_authorization = authorization as BasicAuthorization;
        return authenticate_user (basic_authorization.username, basic_authorization.password);
    });

