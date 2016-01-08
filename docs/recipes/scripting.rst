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

.. code:: bash

    valac --pkg valum-0.1 --pkg lua app.vala

.. code:: vala

    using Valum;
    using VSGI.Soup;
    using Lua;

    var app = new Router ();
    var lua = new LuaVM ();

    // GET /lua
    app.get ("lua", (req, res) => {
        var writer = new DataOutputStream (res.body);

        // evaluate a string containing Lua code
        writer.put_string (lua.do_string (
        """
        require "markdown"
        return markdown('## Hello from lua.eval!')
        """));

        // evaluate a file containing Lua code
        writer.put_string (lua.do_file ("scripts/hello.lua"));
    });

    new Soup (app).run ();

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

.. code:: vala

    app.get ("hello.scm", (req, res) => {
        var writer = new DataOutputStream (res.body);
        writer.put_string (scm.run ("scripts/hello.scm"));
    });

Scheme code:

.. code-block:: scheme

    ;; VALUM_ROOT/scripts/hello.scm
    (+ 1 2 3)
    ;; returned value will be casted to string
    ;; and appended to response body
