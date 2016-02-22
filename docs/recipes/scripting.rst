Scripting
=========

Through `Vala VAPI bindings <https://wiki.gnome.org/Projects/Vala/Bindings>`__,
application written with Valum can embed multiple interpreters and JIT to
provide facilities for computation and templating.

Lua
---

`luajit`_ ships with a VAPI you can use to access a Lua VM, just add
``--pkg lua`` to ``valac``.

.. _luajit: http://luajit.org/

.. code-block:: bash

    valac --pkg valum-0.1 --pkg lua app.vala

.. code-block:: lua

    require 'markdown'
    return markdown('## Hello from lua.eval!')

::

    using Valum;
    using VSGI.HTTP;
    using Lua;

    var app = new Router ();
    var lua = new LuaVM ();

    // GET /lua
    app.get ("lua", (req, res) => {
        // evaluate a string containing Lua code
        res.expand_utf8 (some_lua_code, null);

        // evaluate a file containing Lua code
        return res.expand_utf8 (lua.do_file ("scripts/hello.lua"));
    });

    new Server ("org.valum.example.Lua", app.handle).run ();

The sample Lua script contains:

.. code-block:: lua

    require 'markdown'
    return markdown("# Hello from Lua!!!")
    -- returned value will be appended to response body

Resulting response

.. code-block:: html

    <h1>Hello from Lua!!!</h1>

Scheme (TODO)
-------------

Scheme can be used to produce template or facilitate computation.

::

    app.get ("hello.scm", (req, res) => {
        return res.expand_utf8 (scm.run ("scripts/hello.scm"));
    });

Scheme code:

.. code-block:: scheme

    ;; VALUM_ROOT/scripts/hello.scm
    (+ 1 2 3)
    ;; returned value will be casted to string
    ;; and appended to response body
