This section explains what is going on in a Valum web application using
a sample that can be found in the [Gettings started](getting-started.md)
section of the documentation.

Creating an application
-----------------------

An application is an instance of the `Router` class.

```javascript
var app = new Router ();
```

Binding a route
---------------

An application constitute of a list of routes matching user requests. To declare
a route, the `Router` class provides useful helpers and low-level utilities.

```javascript
app.get("", (req, res) => {
    var writer = new DataOutputStream (res);
    writer.put_string ("Hello world!");
});
```

Every route declaration has a callback associated that does the request
processing. The callback receives two arguments:

 - [Request](vsgi/request.md) representing what is begin requested
 - [Response](vsgi/response.md) representing what will be sent back to
   the requester

These two inherit respectively from `InputStream` and `OutputStream`, allowing
any synchronous and asynchronous stream operations.

Serving the application
-----------------------

This part is pretty straightforward: you create a server that will serve your
application at port `3003`.

It is also to use the `FastCGIServer`, but it needs a specific setup that is
covered in the [FastCGI section](server/fastcgi.md) of the documentation.

```java
new SoupServer (app, 3003).run ();
```
It is also possible to use the [FastCGI server](server/fastcgi.md)
implementation, but it needs a specific setup and a web server supporting the
FastCGI protocol.
