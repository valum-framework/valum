Basepath
========

The :valadoc:`valum-0.3/Valum.basepath` middleware allow a better isolation
when composing routers by stripping a prefix on the :doc:`../vsgi/request` URI.

The middleware strips and forwards requests which match the provided base path.
If the resulting path is empty, it fallbacks to a root ``/``.

Error which use their message as a ``Location`` header are automatically
prefixed by the base path.

::

    var user = new Router ();

    user.get ("/<int:id>", (req, res) => {
        // ...
    });

    user.post ("/", (req, res) => {
        throw new Success.CREATED ("/5");
    });

    app.use (basepath ("/user", user.handle));

    app.status (Soup.Status.CREATED, (req, res) => {
        assert ("/user/5" == context["message"]);
    });

If ``next`` is called while forwarding or an error is thrown, the original path
is restored.

::

    user.get ("/<int:id>", (req, res, next) => {
        return next (); // path is '/5'
    });

    app.use (basepath ("/user", user.handle));

    app.use ((req, res) => {
        // path is '/user/5'
    });

One common pattern is to provide a path-based fallback when using the
:doc:`subdomain` middleware.

::

    app.use (subdomain ("api", api.handle));
    app.use (basepath ("/api", api.handle));
