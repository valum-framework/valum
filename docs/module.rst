Module
======

It is often useful to craft an application as a set of decoupled and reusable
modules. Valum supports subrouting, which can be used to assemble various
routers under a single parent router.

Let's say you need an administration section:

::

    using Valum;

    class AdminRouter : Router {
        construct {
            get ("", (req, res) => {
                // ...
            });
        }
    }

This can be passed to a parent router by using the ``Router.scope`` method. This
way, all registered routes will be prefixed with ``admin/``.

::

    var app = new Router ();
    app.scope ("admin", (admin) => {
        admin.rule (Method.ALL, "*", new AdminRouter ().handle);
    });
