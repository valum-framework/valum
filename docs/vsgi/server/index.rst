Server
======

Server provide HTTP technologies integrations under a common interface. They
inherit from `GLib.Application`_, providing an optimal integration with the
host environment.

.. toctree::
    :caption: Table of Contents

    http
    cgi
    fastcgi
    scgi

General
-------

Basically, you have access to a `DBusConnection`_ to communicate with other
process and a `GLib.MainLoop`_ to process events and asynchronous work.

-  an application id to identify primary instance
-  ``startup`` signal emmited right after the registration
-  ``shutdown`` signal just before the server exits
-  a resource base path
-  ability to handle CLI arguments

.. _DBusConnection: http://valadoc.org/#!api=gio-2.0/GLib.DBusConnection
.. _GLib.MainLoop: http://valadoc.org/#!api=glib-2.0/GLib.MainLoop

DBus connection
---------------

`GLib.Application`_ will automatically register to the session DBus bus, making
IPC (Inter-Process Communication) an easy thing.

It can be used to expose runtime information such as a database connection
details or the amount of processing requests. See this `example of DBus server`_
for code examples.

.. _example of DBus server: https://wiki.gnome.org/Projects/Vala/DBusServerSample

This can be used to request services, communicate between your workers and
interact with the runtime.

.. code:: vala

    var connection = server.get_dbus_connection ()

    connection.call ()

.. _GLib.Application: http://valadoc.org/#!api=gio-2.0/GLib.Application

Options
-------

Each server implementation can optionally take arguments that parametrize its
runtime.

If you build your application in a main block, it will not be possible to
obtain the CLI arguments to parametrize the runtime. Instead, the code can be
written in a usual ``main`` function.

.. code:: vala

    public static int main (string[] args) {
        return new Server ("org.vsgi.App", (req, res) => {
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
      -s, --socket                path to the UNIX socket
      -p, --port                  TCP port on this host
      -f, --file-descriptor=0     file descriptor
      -b, --backlog=0             listen queue depth used in the listen() call


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

    server.run ("app", {"--forks=4"});

It's also possible to fork manually via the ``fork`` call.

::

    using VSGI.HTTP;

    var server = new Server ();

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

    using VSGI.HTTP;

    var server = new Server ();

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

