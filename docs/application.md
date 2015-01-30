Getting started
---------------

This setup application should get you started with Valum.

Copy this code in a file named `app.vala` and call
`valac --pkg valum-0.1 app.vala` to compile the example.

```java
using Valum;
using VSGI;

var app = new Router ();

app.get("", (req, res) => {
    var writer = new DataOutputStream (res);
    writer.put_string ("Hello world!");
});

new SoupServer (app, 3003).listen ();
```

Creating an application
-----------------------

An application is an instance of the `Router` class

```java
var app = new Router ();
```

Binding a route
---------------

An application constitute of a list of routes matching user requests. To declare
a route, the `Router` class provides useful helpers and low-level utilities.

`Response` (`res` in this case) in Vala are `OutputStream`, so for convenience,
you can wrap it with a `DataOutputStream` that provide facilities to write
strings, bytes and many more.

```java
app.get("", (req, res) => {
    var writer = new DataOutputStream (res);
    writer.put_string ("Hello world!");
});
```

Using the Soup built-in server
------------------------------

Implementations of application are based on VSGI middleware. This is why you can
use an arbitrary server to serve them.

This part is pretty straightforward: you create a server that will serve your
application at port `3003`.

It is also to use the `FastCGIServer`, but it needs a specific setup that is
covered in the [FastCGI section](server/fastcgi.md) of the documentation.

```java
new SoupServer (app, 3003).listen ();
```
