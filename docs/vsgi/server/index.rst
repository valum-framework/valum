Server
======

Server provide HTTP technologies integrations under a common interface. They
inherit from `GLib.Application`_, providing an optimal integration with the
host environment.

.. toctree::
    :caption: Table of Contents

    soup
    fastcgi

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

To identify your workers, you can use the ``set_application_id`` function.

.. code:: vala

    server.set_application_id ("worker");

This can be used to request services and communicate between your workers and
interact with the runtime.

.. code:: vala

    var connection = server.get_dbus_connection ()

    connection.call ()

.. _GLib.Application: http://valadoc.org/#!api=gio-2.0/GLib.Application

Options
-------

Each server implementation can optionally take arguments that parametrize their
runtime. Generally, you can set the following options:

-  a socket path or a TCP port
-  backlog
-  inactivity timeout

If you build your application in a main block, it is not possible to obtain the
CLI arguments, so you must write your code in a ``main`` function.

.. code:: vala

    public static int main (string[] args) {
        var app = new Router;

        app.get ("", (req, res) => {
            res.body.write ("Hello world!".data);
        });

        return new Server (app).run (args);
    }

If you specify the ``--help`` flag, you can get more information on the
available options.

.. code:: bash

    build/examples/fastcgi --help

.. code:: bash

    Usage:
      fastcgi [OPTION...]

    Help Options:
      -h, --help                 Show help options
      --help-all                 Show all help options
      --help-gapplication        Show GApplication options

    Application Options:
      -s, --socket               path to the UNIX socket
      -p, --port                 TCP port on this host
      -b, --backlog=0            listen queue depth used in the listen() call
      -t, --timeout=0            inactivity timeout in ms

Socket
~~~~~~

In some context, you do not want to serve your application over a TCP socket,
but just a local socket. Either this or ``--port`` can be specified, but not
both.

Port
~~~~

This is the TCP port on which the application will be exposed on the local
host.

Backlog
~~~~~~~

The backlog correspond to the depth on the ``listen`` call and is used if you
have multiple listener on a socket.

Inactivity timeout
~~~~~~~~~~~~~~~~~~

An inactivity timeout can be set to exit automatically after a certain amount
of milliseconds if no request is being processed.

The server keeps track of the number of processing requests with ``hold`` and
``release`` from `GLib.Application`_. When the amount reaches 0, the server
will exit automatically after the value of the inactivity timeout.

This option is enabled if the default timeout value is greater than 0.

.. _GLib.Application: http://valadoc.org/#!api=gio-2.0/GLib.Application


