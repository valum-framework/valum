Module
======

It is often useful to construct an application as a set of decoupled and
reusable modules. This can easily be done with the ``Router.Loader``
delegate definition. A module is represented by a simple callback that
takes a ``Router`` as input and register routes to it as a side-effect.

Let's say you need an administration section:

.. code:: vala

    using Valum;

    /**
     * Loads administrative routes on a provided router.
     */
    public static Router.Loader admin_loader = (Router admin) {
        admin.get ("", (req, res) => {
            // ...
        });
    }

Then you can easily load your module into a concrete one:

.. code:: vala

    using Valum;

    var app = new Router ();

    admin_loader (app);

Since the ``Router.scope`` method takes a ``Router.Loader`` argument,
you can simply scope your module route definitions. This way, all
registered routes will be prefixed with ``admin/``.

.. code:: vala

    using Valum;

    var app = new Router ();

    app.scope ("admin", admin_loader);

If you distribute your code, use namespaces to avoid conflicts:

.. code:: vala

    using Valum;

    namespace Admin {
        public static void admin_loader (Router admin) {
            admin.get ("", (req, res) => {
                // ...
            });
        }
    }
