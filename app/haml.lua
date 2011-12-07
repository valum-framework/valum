-- $ sudo apt-get install luarocks
-- $ luarocks install luahaml
require "luarocks.loader"

local haml   = require "haml"
local engine = haml.new({format = "html5"})
local locals = {
   title = "Haml rendered by Lua",
   body  = "luarocks install luahaml"
}

return engine:render_file("./app/lua.haml", locals)
