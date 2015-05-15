Scripting
=========

Through `Vala VAPI
bindings <https://wiki.gnome.org/Projects/Vala/Bindings>`__, application
written on Valum can support multiple interpreters and JIT providing
facilities for computation and templating.

Basically, we provide `CTPL <ctpl>`__, but you might want to have
something a little more powerful, so this section should fit your needs.

Lua
---

Valum currently supports embedded Lua as a templating and computation
engine.

.. code:: vala

    using Valum;

    var app = new Router();
    var lua = new Script.Lua();

    // GET /lua
    app.get("lua", (req, res) => {
        var writer = new DataOutputStream (res);

        writer.put_string (lua.eval("""
        require "markdown"
        return markdown('## Hello from lua.eval!')
        """));

        writer.put_string (lua.run("scripts/hello.lua"));
    });

    new SoupServer (app, 3003).run ();

The sample Lua script contains:

.. code:: lua

    require 'markdown'
    return markdown("# Hello from Lua!!!")
    -- returned value will be appended to response body

Resulting response

.. code:: html

    <h1>Hello from Lua!!!</h1>

Scheme (TODO)
-------------

Scheme can be used to produce template or facilitate computation.

.. code:: vala

    app.get("hello.scm", (req, res) => {
        var writer = new DataOutputStream (res);
        res.put_string (scm.run ("scripts/hello.scm"));
    });

Scheme code:

.. code:: scheme

    ;; VALUM_ROOT/scripts/hello.scm
    (+ 1 2 3)
    ;; returned value will be casted to string
    ;; and appended to response body
