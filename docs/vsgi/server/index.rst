Server
======

Server provide HTTP technologies integrations under a common interface.

.. toctree::
    :caption: Table of Contents

    http
    cgi
    fastcgi
    scgi

Cushion
-------

The ``Application`` class provide a nice cushion around ``Server`` that deals
with pretty logging and CLI argument parsing.

The ``Server.run`` function actually create a new application object around the
server instance. Thus, the following snippets are equivalent:

::

    using VSGI;

    Server.new ("http").run ();

::

    using VSGI;

    new Application (Server.new ("http")).run ();

Load an implementation
----------------------

Server implementations are dynamically loaded using `GLib.Module`_. It makes it
possible to define its own implementation if necessary.

.. _GLib.Module: http://valadoc.org/#!api=gmodule-2.0/GLib.Module

The shared library name must conform to ``libvsgi-<name>`` with the appropriate
extension. For instance, on GNU/Linux, the :doc:`cgi` module is stored in
``${prefix}/${libdir}/vsgi-0.3/servers/libvsgi-cgi.so``.

To load an implementation, use the ``Server.new`` factory, which can receive
GObject-style arguments as well.

::

    var cgi_server = Server.new ("cgi");

    if (cgi_server == null) {
        assert_not_reached ();
    }

    cgi_server.set_application_callback ((req, res) => {
        return res.expand_utf8 ("Hello world!");
    });

For typical case, use ``Server.new_with_application`` to initialize the
instance with an application identifier and callback:

::

    var cgi_server = Server.new_with_application ("cgi", "org.example.CGI", (req, res) => {
        return true;
    });

For more flexibility, the ``ServerModule`` class allow a more fine-grained
control for loading a server implementation. If non-null, the ``directory``
property will be used to retrieve the implementation from the given path
instead of standard locations.

The computed path of the shared library is available from ``path`` property,
which can be used for debugging purposes.

::

    var directory  = "/usr/lib64/vsgi/servers";
    var cgi_module = new ServerModule (directory, "cgi");

    if (!cgi_module.load ()) {
        error ("could not load 'cgi' from '%s'", cgi_module.path);
    }

    var server = Object.new (cgi_module.server_type);

Unloading a module is not necessary: once initially loaded, a use count is kept
so that it can be loaded on need or unloaded if not used.

.. warning::

    Since a ``ServerModule`` cannot be disposed (see `GLib.TypeModule`_), one
    must be careful of how its reference is being handled. For instance,
    ``Server.new`` keeps track of requested implementations and persist them
    forever.

.. _GLib.TypeModule: http://valadoc.org/#!api=gobject-2.0/GLib.TypeModule

Mixing direct usages of ``ServerModule`` and ``Server.@new`` (and the likes) is
not recommended and will result in undefined behaviours if an implementation is
loaded more than once.

Options
-------

Each server implementation can optionally take arguments that parametrize its
runtime.

The available options are listed in ``get_listen_options`` in the form of
a list of `GLib.OptionEntry`_ structs.

.. _GLib.OptionEntry: http://valadoc.org/#!api=glib-2.0/GLib.OptionEntry

If you build your application in a main block, it will not be possible to
obtain the CLI arguments to parametrize the runtime. Instead, the code can be
written in a usual ``main`` function.

.. code:: vala

    public int main (string[] args) {
        return Server.new ("http", "org.vsgi.App", (req, res) => {
            res.status = Soup.Status.OK;
            return res.body.write_all ("Hello world!".data, null);
        }).run (args);
    }

If you specify the ``--help`` flag, you can get more information on the
available options which vary from an implementation to another.

.. code:: bash

    build/examples/fastcgi --help

.. code:: bash

    Usage:
      fastcgi [OPTION...]

    Help Options:
      -h, --help                  Show help options
      --help-all                  Show all help options
      --help-gapplication         Show GApplication options

    Application Options:
      --forks=0                   Number of fork to create
      -s, --socket                Listen to the provided UNIX domain socket (or named pipe for WinNT)
      -p, --port                  Listen to the provided TCP port
      -f, --file-descriptor=0     Listen to the provided file descriptor
      -b, --backlog=10            Listen queue depth used in the listen() call

Forking
-------

To achieve optimal performances on a multi-core architecture, VSGI support
forking at the server level.

.. warning::

    Keep in mind that the ``fork`` system call will actually copy the whole
    process: no resources (e.g. lock, memory) can be shared unless
    inter-process communication is used.

The ``--forks`` option will spawn the requested amount of workers, which should
optimally default to the number of available CPUs.

::

    server.run ({"app", "--forks=4"});

It's also possible to fork manually via the ``fork`` call.

::

    using VSGI;

    var server = Server.new ("http");

    server.listen (options);
    server.fork ();

    new MainLoop ().run ();

It is recommended to fork only through that call since implementations such as
:doc:`cgi` are not guaranteed to support it.

Listen on distinct interfaces
-----------------------------

Typically, ``fork`` is called after ``listen`` so that all processes share the
same file descriptors and interfaces. However, it might be useful to listen
to multiple ports (e.g. HTTP and HTTPS).

::

    using VSGI;

    var server = Server.new ("http");

    var parent_options = new VariantDict ();
    var child_options = new VariantDict ();

    // parent serve HTTP
    parent_options.insert_value ("port", new Variant.int32 (80));

    // child serve HTTPS
    child_options.insert_value ("https");
    child_options.insert_value ("port", new Variant.int32 (443));

    if (server.fork () > 0) {
        server.listen (parent_options);
    } else {
        server.listen (child_options);
    }

    new MainLoop ().run ();

