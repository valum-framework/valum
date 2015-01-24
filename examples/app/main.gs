[indent=2]

// FIXME
init
  var app = new Valum.Server()
  var lua = new Valum.Script.Lua();
  print "Hello World"       
  var handler = def (req, res)
    res.append(lua.eval("print 'hi from lua string'"))
  app.get("/", handler)
  
