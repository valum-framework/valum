Module
======

It is often useful to craft an application as a set of decoupled and reusable
modules. This can easily be done with the ``LoaderCallback`` delegate which is
used for the scope feature. A module is represented by a simple callback that
takes a :doc:`router` as input and register some routes on it.

Let's say you need an administration section:

.. code:: vala

    using Valum;

    public static LoaderCallback admin_loader = (admin) {
        admin.get ("", (req, res) => {
            // ...
        });
    }

Then you can easily load your module into a concrete one:

.. code:: vala

    using Valum;

    var app = new Router ();

    admin_loader (app);

Since the ``Router.scope`` method takes a ``LoaderCallback`` argument, you can
simply scope your module route definitions. This way, all registered routes
will be prefixed with ``admin/``.

.. code:: vala

    using Valum;

    var app = new Router ();

    app.scope ("admin", admin_loader);

Distributed code should be namespaced to avoid conflicts:

.. code:: vala

    using Valum;

    namespace Admin {
        public static void admin_loader (Router admin) {
            admin.get ("", (req, res) => {
                // ...
            });
        }
    }
