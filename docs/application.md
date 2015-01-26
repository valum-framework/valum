This setup application should get you started with Valum.

Copy this code in a file named `app.vala` and call
`valac --pkg valum-0.1 app.vala` to compile the example.

```java
using Soup;
using Valum;

var app = new Router ();

app.get("", (req, res) => {
    res.append("Hello world!");
});

var server = new Soup.Server(Soup.SERVER_SERVER_HEADER, Valum.APP_NAME);

// bind the application to the server
server.add_handler("/", app.request_handler);

try {
	server.listen_local(3003, Soup.ServerListenOptions.IPV4_ONLY);
} catch (Error error) {
	stderr.printf("%s.\n", error.message);
}
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

```java
app.get ("", (req, res) => {
    res.append ("Hello world!");
});
```

Using the Soup built-in server
------------------------------

```java
var server = new Soup.Server(Soup.SERVER_SERVER_HEADER, Valum.APP_NAME);

// bind the application to the server
server.add_handler("/", app.request_handler);

try {
	server.listen_local(3000, Soup.ServerListenOptions.IPV4_ONLY);
} catch (Error error) {
	stderr.printf("%s.\n", error.message);
}
```
