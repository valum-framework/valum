Route
=====

Route associate regular expression that matches request path with a callback
that is executed on user request.

Rules
-----

This class implements the rule system designed to simplify regular expression.

The following are rules examples:

 - `/user`
 - `/user/<id>`
 - `/user/<int:id>`

These will respectively compile down to the following regular expressions

 - `^/user$`
 - `^/user/(?<id>\w+)`
 - `^/user/(?<id>\d+)`

In this example, we call `<id>` a parameter and `<int>` a type. These two
definitions will be important for the rest of the document.

Types
-----

Valum provides the following built-in types

 - int that matches `\d+`
 - string that matches `\w+` (this one is implicit)
 - any that matches `.+` asad

Undeclared type is assumed to be `string`, this is what implicit meant.

The `ìnt` type is useful for matching non-negative identifier such as database
primary key.

The `any` type is useful to create catch-all route. The sample application shows
an example for creating a 404 error page.

```java
app.get('<any:path>', (req, res) => {
    res.status = 404;
});
```

It is possible to specify new types using the `types` map in `Router`. This
example will define the `path` type matching words and slashes.

```java
app.types["path"] = "[\\w/]+";
```

Types are defined at construct time of the `Router` class. It is possible to
overwrite the built-in type.

If you would like `ìnt` to match negatives integer, you may just do:

```java
app = new Router ();

app.types["int"] = "-?\d+";
```

Plumbering with regular expression
----------------------------------

If the rule system does not suit your needs, it is always possible to use
regular expression.

```java
app.regex ("GET", /^/home/?$/, (req, res) => {

});
```

Plumbering with Route
---------------------

In some scenario, you need more than a just matching the request path using a
regular expression. Internally, Route uses a matcher pattern and it is possible
to define them yourself.

A matcher consist of a callback matching a given `Request` object.

```java
Route.RequestMatcher matcher = (req) => { req.path == "/custom-matcher"; };

app.matcher ("GET", matcher, (req, res) => {
    res.append ("Matched using a custom matcher.");
});
```

You could, for instance, match the request if the user is an administrator and
fallback to a default route otherwise.

```java
app.matcher ("GET", (req) => {
    var user = new User (req.query["id"]);
    return "admin" in user.roles;
}, (req, res) => {});

app.route ("<any:path>", (req, res) => {
    res.status = 404;
});
```
