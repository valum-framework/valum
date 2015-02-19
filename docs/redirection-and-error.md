Redirection, client and server errors are handled via a simple
[exception](https://wiki.gnome.org/Projects/Vala/Manual/Errors) mechanism.

In a [Route](route.md) callback, you may throw any of `Redirection`,
`ClientError` and `ServerError` predefined error domains rather than setting
the status and returning from the function.

The Router handler will automatically catch these special errors and set the
appropriate status code in the response for your convenience.

## Redirection (3xx)

To perform a redirection, you have to throw a `Redirection` error and use the
message as a redirect URL.

```javascript
app.get ("user/<id>/save", (req, res) => {
    var user = User (req.params["id"]);

    if (user.save ())
        throw new Redirection.MOVED_TEMPORAIRLY ("/user/%u".printf (user.id));
});
```

## Client (4xx) and server (5xx) error

Just like for redirection, client and server errors are thrown.

Errors are predefined in `ClientError` and `ServerError` enumerations.

```javascript
app.get ("not-found", (req, res) => {
    throw new ClientError.NOT_FOUND ("The requested URI was not found.");
});
```

## Custom handling for status

To do custom handling for specific status, bind a callback after the router
handler execution.

```javascript
app.handle.connect_after ((req, res) => {
    if (res.status == Soup.Status.NOT_FOUND) {
        // produce a 404 page...
    }
});
```
