Guidelines
==========

To ease application development and decision processing, this document present
some guidelines to structure and organize code in a Web application.

While Valum adopted a more flat layout, it is recommended to keep a minimal
folder organization to keep code easily traversable as applications tend to
become somewhat populous over time.

::

    src/
        app.vala
        model/
            model-user.vala
        controller/
            controller-user.vala
        view/
            user.html
    vapi/
    vendor/

Include the last namespace or its abbreviation in the file name as this is
pretty much the norm across GLib software. Read more on `Yorba's page`_ about
Geary and Shotwell coding practices.

.. _Yorba's page: http://gnome.org

Since applications are mostly domain oriented, it is a good practice to reuse
names across related concepts. Introduce names to disambiguate and make evident
the semantic of relationships (e.g. ``model-membership`` instead of ``model-user-group``).

Use ``src/app.vala`` as the main entry point of your application, where all
other middlewares are mounted and the server is launched. Using the
:doc:`../middlewares/basepath` middleware, you can make most of your
controllers agnostics of the used path prefix.

::

    var app = new Router ();

    app.use (basepath ("/users", Controller.user ()));

    Server.new_with_application ("http". app.handle);

Don't mix frontend and backend code: favour separate repositories as they are
likely to use a completely different set of technologies. Let the communication
happen through an well-defined Web API.

Some of the provided middlewares are particularly useful:

-   :doc:`middlewares/authenticate` to authenticate users
-   :doc:`middlewares/content-negotiation` to negotiate a representation: think of
     HTML for human and JSON for client
-   :doc:`middlewares/server-sent-events` if the frontend needs to poll data

Controllers
-----------

Using the middleware definition and `Router.handle`, one can easily build
controllers:

::

    namespace Controller {
        public HandlerCallback user () {
            var app = new Router ();

            app.get ("/", () => {
                // TODO: list all users
            });

            app.get ("/<int:id>" () => {
                // TODO: show user identified by 'id'
            });

            return app.handle;
        }
    }

Or by subclassing :doc:`router`:

::

    public class Controller.UserRouter : Router {
        construct {
            get ("/", () => {
                // TODO: list all users
            });

            get ("/<int:id>", () => {
                // TODO: show user identified by 'id'
            });
        }
    }

Models
------

Use plain `GLib.Object` for models, they already provide a nice way of holding
immutable data with construct properties and they can be introspected for
automatic serialization and deserialization.

Serialization
~~~~~~~~~~~~~

Keep model and serialization separated. Introduce ``<format>.Serializable``
interfaces to let models override how they are represented in specific formats.

-  JSON with JSON-GLib
-  XML with GXml
-  GVariant
-  MessagePack with MessagePack-GLib
-  MessagePack using JSON-MessagePack-GLib

To organize payloads effectively and add some semantics, look into `JSON-API`_
and `JSON-LD`_. For the former, `JSON-API-GLib`_ provides serializable objects
to avoid most of the boilerplate.

.. _JSON-API: http://jsonapi.org/
.. _JSON-API-GLib: https://github.com/major-lab/json-api-glib
.. _JSON-LD: http://json-ld.org/

Views
-----

For views, use a template engine like `Compose`_ or `Template-GLib`_. Use
``GLib.Resource`` to bundle them during the compilation. Serve any static files
using one of the :doc:`../middlewares/static` middlewares.

.. _Compose:
.. _Template-GLib:


Headers
-------

Move as much as possible outside the scope of the application. Here's a few
things that should not be part:

-   caching (see `mod_cache`\_ and `nginx cache`\_)
-   HTTPS enforcement (e.g. redirection, HSTS)

Those which should be part:

 - ``Cache-Control`` directives
 - compression

Move as much as possible at the frontend.
