Static Resource Delivery
========================

Middlewares in the :valadoc:`valum-0.3/Valum.Static` namespace ensure delivery
of static resources.

::

    using Valum.Static;

As of convention, all middleware use the ``path`` context key to resolve the
resource to be served. This can easily be specified using a rule parameter with
the ``path`` type.

For more flexibility, one can compute the ``path`` value and pass the control
with ``next``. The following example obtains the key from the HTTP query:

::

    app.get ("/static", sequence ((req, res, next, ctx) => {
        ctx["path"] = req.lookup_query ("path") ?? "index.html";
        return next ();
    }, serve_from_file (File.new_for_uri ("resource://"))));

If a ``HEAD`` request is performed, the payload will be omitted.

File backend
-------------

The :valadoc:`valum-0.3/Valum.Static.serve_from_file` middleware will serve
resources relative to a :valadoc:`gio-2.0/GLib.File` instance.

::

    app.get ("/static/<path:path>", serve_from_file (File.new_for_path ("static")));

To deliver from the global resources, use the ``resource://`` scheme.

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

Helpers
~~~~~~~

Two helpers are provided for File-based delivery: :valadoc:`valum-0.3/Valum.Static.serve_from_path`
and :valadoc:`valum-0.3/Valum.Static.serve_from_uri`.

::

    app.get ("/static/<path:path>", serve_from_path ("static/<path:path>"));

    app.get ("/static/<path:path>", serve_from_uri ("static/<path:path>"));

Resource backend
-----------------

The :valadoc:`valum-0.3/Valum.Static.serve_from_resource` middleware is
provided to serve a resource bundle (see :valadoc:`gio-2.0/GLib.Resource`) from
a given prefix. Note that the prefix must be a valid path, starting and ending
with a slash ``/`` character.

::

    app.get ("/static/<path:path>", serve_from_resource (Resource.load ("resource"),
                                                         "/static/"));

Compression
-----------

To compress static resources, it is best to negotiate a compression encoding
with a :doc:`content-negotiation` middleware: body stream and headers will be
set properly if the encoding is supported.

Using the ``identity`` encoding provide a fallback in case the user agent does
not want compression and prevent a ``406 Not Acceptable`` from being raised.

::

    app.get ("/static/<path:path>", sequence (accept_encoding ("gzip, deflate, identity"),
                                              serve_from_path ("static")));

Content type detection
----------------------

The middlewares will detect the content type based on the file name and
a lookup on its content.

Content type detection, based on the file name and a small data lookup, is
performed with `GLib.ContentType`_.

.. _GLib.ContentType: http://valadoc.org/#!api=gio-2.0/GLib.ContentType

Deal with missing resources
---------------------------

If a resource is not available (eg. the file does not exist), the control will
be forwarded to the next route.

One can use that behaviour to implement a cascading failover with the
:doc:`sequence` middleware.

::

    app.get ("/static/<path:path", sequence (serve_from_path ("~/.local/app/static"),
                                             serve_from_path ("/usr/share/app/static")));

To generate a ``404 Not Found``, just raise a :valadoc:`valum-0.3/Valum.ClientError.NOT_FOUND`
as described in :doc:`../redirection-and-error`.

::

    app.use (basic ());

    app.get ("/static/<path:path>", sequence (serve_from_uri ("resource://"),
                                              (req, res, next, ctx) => {
        throw new ClientError.NOT_FOUND ("The static resource '%s' were not found.",
                                         ctx["path"]);
    }));

Options
-------

Options are provided as flags from the :valadoc:`valum-0.3/Valum.Static.ServeFlags`
enumeration.

ETag
~~~~

If the :valadoc:`valum-0.3/Valum.Static.ServeFlags.ENABLE_ETAG` is specified,
a checksum of the resource will be generated in the ``ETag`` header.

If set and available, it will have precedence over valadoc:`valum-0.3/Valum.Static.ServeFlags.ENABLE_LAST_MODIFIED`
described below.

Last-Modified
~~~~~~~~~~~~~

Unlike ``ETag``, this caching feature is time-based and will indicate the last
modification on the resource. This is only available for some File backend and
will fallback to ``ETag`` if enabled as well.

Specify the :valadoc:`valum-0.3/Valum.Static.ServeFlags.ENABLE_LAST_MODIFIED`
to enable this feature.

X-Sendfile
~~~~~~~~~~

If the application run behind a HTTP server which have access to the resources,
it might be preferable to let it serve them directly with :valadoc:`valum-0.3/Valum.Static.ServeFlags.X_SENDFILE`.

::

    app.get ("/static/<path:path>", serve_from_path ("static", ServeFlags.X_SENDFILE));

If files are not locally available, they will be served directly.

Public caching
~~~~~~~~~~~~~~

The :valadoc:`valum-0.3/Valum.Static.ServeFlags.ENABLE_CACHE_CONTROL_PUBLIC`
let intermediate HTTP servers cache the payload by attaching a ``Cache-Control: public``
header to the response.

Expose missing permissions
~~~~~~~~~~~~~~~~~~~~~~~~~~

The :valadoc:`valum-0.3/Valum.Static.ServeFlags.FORBID_ON_MISSING_RIGHTS` will
trigger a ``403 Forbidden`` if rights are missing to read a file. This is not
a default as it may expose information about the existence of certain files.
