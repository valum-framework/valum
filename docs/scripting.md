Embedded Lua
------------

```java
var app = new Valum.Router();
var lua = new Valum.Script.Lua();

// GET /lua
app.get("lua", (req, res) => {
  res.append(lua.eval("""
    require "markdown"
    return markdown('## Hello from lua.eval!')
  """));

  res.append(lua.run("app/hello.lua"));
});
```

This code works with either Lua or LuaJIT depending
on `--pkg` option in `Makefile`. See ./vapi/lua[jit].vapi for
details.

We are going to implement simplier syntax for lua scripts:

Vala code:

```java
app.get("lua.html", app.lua("hello"));
```

Lua code:

```lua
-- VALUM_ROOT/scripts/hello.lua
require 'markdown'
return markdown("# Hello from Lua!!!")
-- returned value will be appended to response body
```

Resulted html:
```html
<h1> Hello from Lua!!! </h1>
```

Scheme (TODO)
-------------

```java
app.get("hello.scm", app.scm("hello"));
```

Scheme code:

```scheme
;; VALUM_ROOT/scripts/hello.scm
(+ 1 2 3)
;; returned value will be casted to string
;; and appended to response body
```
