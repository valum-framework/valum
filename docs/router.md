Router is the core component of Valum. It dispatches request to the right
handler and processes certain error conditions described in
[Redirection and Error](redirection-and-error).


## HTTP methods

Callback can be connected to HTTP methods via a list of helpers having the
`Route.Handler` signature:

```javascript
app.get ("rule", (req, res) => {});
```

Valum includes helpers for the HTTP/1.1 protocol and the extra TRACE method.

 - `get`
 - `post`
 - `put`
 - `delete`
 - `connect`
 - `trace`

Handling a `POST` request would be something like

```javascript
app.post ("login", (req, res) => {
    var data = Soup.Form.decode (req.body);

    var username = data["username"];
    var password = data["password"];

    // assuming you have a session implementation in your app
    var session = app.authenticate (username, password);
});
```

It is also possible to use a custom HTTP method via the `method` function.

```java
app.method ("METHOD", "rule", (req, res) => {});
```


## Scoping

Scoping is a powerful prefixing mechanism for rules. Route declarations within
a scope will be prefixed by `<scope>/`. There is an implicit initial scope so
that all rules are automatically rooted.

The `Router` maintains a scope stack so that when the program flows you enter a
scope, it pushes the fragment on top of it and pop it when it gets out.

```java
app.scope ("admin", (admin) => {
    // admin is a scoped Router
    app.get ("users", (req, res) => {
        // matches /admin/users
    });
});

app.get ("users", (req, res) => {
    // matches /users
});
```
