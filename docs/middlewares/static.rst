Static Resource Delivery
========================

Middlewares in the ``Valum.Static`` namespace ensure delivery of static
resources.

::

    using Valum.Static;

As of convention, all middleware use the ``path`` context key to resolve the
resource to be served. This can easily be specified using a rule parameter with
the ``path`` type.

For more flexibility, one can compute the ``path`` value and pass the control
with ``next``. The following example obtain the key form the HTTP query:

::

    app.get ("/", sequence ((req, res, next, ctx) => {
        ctx["path"] = req.lookup_query ("path") ?? "index.html";
        return next ();
    }, serve_from_file (File.new_for_uri ("resource://"))));

If a resource is not available (eg. the file does not exist), the control will
be forwarded to the next route. The :doc:`sequence` middleware should be used
to turn that behaviour into a ``404 Not Found``.

::

    app.get ("/", sequence (serve_from_file (File.new_for_uri ("resource://")),
                            (req, res, next, ctx) => {
        throw new ClientError.NOT_FOUND ("The static resource '%s' were not found.", ctx["path"]);
    }));

GFile
-----

The ``serve_from_file`` middleware will serve resources relative to
a `GLib.File`_ instance.

::

    app.get ("/static/<path:path>", serve_from_file (File.new_for_path ("static")));

To deliver from the global resources, use the ``resource://`` scheme.

.. _GLib.File: http://valadoc.org/#!api=gio-2.0/GLib.File

::

    app.get ("/static/<path:path>", serve_from_file (File.new_for_uri ("resource://static")));

Before being served, each file is forwarded to make it possible to modify
headers more specifically or raise a last-minute error.

Once done, invoke the ``next`` continuation to send over the content.

::

    app.get ("/static/<path:path>", serve_from_file (File.new_for_path ("static"),
                                                     ServeFlags.NONE,
                                                     (req, res, next, ctx, file) => {
        var user = ctx["user"] as User;
        if (!user.can_access (file)) {
            throw new ClientError.FORBIDDEN ("You cannot access this file.")
        }
        return next ();
    }));

The ``ServeFlags.X_SENDFILE`` will only work for locally available files,
meaning that `GLib.File.get_path`_ is non-null.

.. _GLib.File.get_path: http://valadoc.org/#!api=gio-2.0/GLib.File.get_path

Resource bundle
---------------

The ``serve_from_resource`` middleware is provided to serve a resource bundle
(see `GLib.Resource`_) from a given prefix.

.. _GLib.Resource: http://valadoc.org/#!api=gio-2.0/GLib.Resource

::

    app.get ("/static/<path:path>", Static.serve_from_resource (Resource.load ("resource"),
                                                                "/static/"));

The ``ServeFlags.ENABLE_LAST_MODIFIED`` is not supported since the necessary
information cannot be determined.

The ``ServeFlags.X_SENDFILE`` is not supported since contained resources are
not represented on the filesystem.

Options
-------

ETag
~~~~

If the ``ServeFlags.ENABLE_ETAG`` is specified, a checksum of the resource will
be generated in the ``ETag`` header.

If set and available, it will have precedence over
``ServeFlags.ENABLE_LAST_MODIFIED`` described below.

Last-Modified
~~~~~~~~~~~~~

Unlike ``ETag``, this caching feature is time-based and will indicate the last
modification on the resource. This is only available for some GFile backend and
will fallback to ``ETag`` if enabled as well.

Specify the ``ServeFlags.ENABLE_LAST_MODIFIED`` to enable this feature.

X-Sendfile
~~~~~~~~~~

If the application run under a HTTP server, it might be preferable to let it
serve static resources directly.

Public caching
~~~~~~~~~~~~~~

The ``ServeFlags.ENABLE_PUBLIC`` let intermediate HTTP servers cache the
payload.

Expose missing permissions
~~~~~~~~~~~~~~~~~~~~~~~~~~

The ``ServeFlags.FORBID_ON_MISSING_RIGHTS`` will trigger a ``403 Forbidden`` if
rights are missing to read a file. This is not a default as it may expose
information about the existence of certain files.
