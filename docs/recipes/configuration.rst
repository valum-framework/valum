Configuration
=============

There exist various way of providing a runtime configuration.

If you need to pass secrets, take a look at the `Libsecret`_ project. It allows
one to securely store and retrieve secrets: just unlock the keyring and start
your service.

.. _Libsecret: https://wiki.gnome.org/Projects/Libsecret

Key file
--------

GLib provide a very handy way of reading and parsing `key files`_, which are
widely used across freedesktop specifications.

It should be privileged if the configuration is mostly edited by humans.

.. _key files: https://developer.gnome.org/glib/stable/glib-Key-value-file-parser.html

.. code-block:: ini

    [app]
    public-dir=public

    [database]
    provider=mysql
    connection=
    auth=

::

    using GLib;
    using Valum;

    var config = new KeyFile ();

    config.parse_path ("app.conf");

    var app = new Router ();

    app.get ("/public/<path:path>",
             Static.serve_from_path (config.get_string ("app", "public-dir")));

JSON
----

The `JSON-GLib`_ project provide a really convenient JSON parser and generator.

.. _JSON-GLib: https://wiki.gnome.org/Projects/JsonGlib

.. code-block:: json

    {
        "app": {
            "publicDir": "public"
        },
        "database": {
            "provider": "mysql",
            "connection": "",
            "auth": ""
        }
    }

::

    using Json;
    using Valum;

    var parser = new Parser ();
    parser.parse_from_file ("config.json");

    var config = parser.get_root ();

    var app = new Router ();

    app.get ("/public/<path:path>",
             Static.serve_from_path (config.get_object ("app").get_string_member ("publicDir")));

YAML
----

There is a `GLib wrapper around libyaml`_ that makes it more convenient to use.
YAML in itself can be seen as a human-readable JSON format.

.. _GLib wrapper around libyaml: https://github.com/fengy-research/libyaml-glib

.. code-block:: yaml

    app:
        publicDir: public
    database:
        provider: mysql
        connection:
        auth:

::

    using Valum;
    using Yaml;

    var config = new Document.from_path ("config.yml").root as Node.Mapping;

    var app = new Router ();

    app.get ("/public/<path:path>",
             Static.serve_from_path (config.get_mapping ("app").get_scalar ("publicDir").value));

Other approaches
----------------

The following approaches are a bit more complex to setup but can solve more
specific use cases:

-   `GXml`_ or libxml2
-   `GSettings`_ for a remote (via DBus) and monitorable configuration
-   environment variables via `GLib.Environment`_ utilities
-   CLI options (see ``VSGI.Server.add_main_option`` and ``VSGI.Server.handle_local_options``)

.. _GXml: https://wiki.gnome.org/GXml
.. _GSettings: https://developer.gnome.org/GSettings/
.. _GLib.Environment: http://www.valadoc.org/#!api=glib-2.0/GLib.Environment

