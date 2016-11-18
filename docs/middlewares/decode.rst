Decode
======

The :valadoc:`valum-0.3/Valum.decode` middleware is used to unapply various
content codings.

::

    app.use (decode ());

    app.post ("/", (req, res) => {
        var posted_data = req.flatten_utf8 ();
    });

It is typically put at the top of an application.

=============== ========================================
Encoding        Action
=============== ========================================
deflate         :valadoc:`gio-2.0/GLib.ZlibDecompressor`
gzip and x-gzip :valadoc:`gio-2.0/GLib.ZlibDecompressor`
identity        nothing
=============== ========================================

If an encoding is not supported, a ``501 Not Implemented`` is raised and
remaining encodings are *reapplied* on the request.

To prevent this behavior, the :valadoc:`valum-0.3/Valum.DecodeFlags.FORWARD_REMAINING_ENCODINGS`
flag can be passed to forward unsupported content codings.

::

    app.use (decode (DecodeFlags.FORWARD_REMAINING_ENCODINGS));

    app.use (() => {
        if (req.headers.get_one ("Content-Encoding") == "br") {
            req.headers.remove ("Content-Encoding");
            req.convert (new BrotliDecompressor ());
        }
        return next ();
    });

    app.post ("/", (req, res) => {
        var posted_data = req.flatten_utf8 ();
    });


