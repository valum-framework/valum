This section explains what is going on in a Valum web application using
a sample that can be found in the [Gettings started](getting-started.md)
section of the documentation.


## Creating an application

An application is an instance of the `Router` class.

```javascript
var app = new Router ();
```


## Binding a route

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


## Serving the application

This part is pretty straightforward: you create a server that will serve your
application at port `3003`. This will use the libsoup built-in HTTP server.

```java
new SoupServer (app, 3003).run ();
```

There is a [FastCGI implementation](server/fastcgi.md) for a live deployment.
