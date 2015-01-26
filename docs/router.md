HTTP methods
------------

Callback can be connected to HTTP methods via a list of helpers having the
following signature:

```java
app.get ("rule", (req, res) => {});
```

Valum includes helpers for the HTTP/1.1 protocol and the extra TRACE method.

 - `get`
 - `post`
 - `put`
 - `delete`
 - `connect`
 - `trace`

It is also possible to use a custom HTTP method, though not recommended.

```java
app.method ("METHOD", "rule", (req, res) => {});
```

Scoping
-------

The scope feature allow a scoped declaration of route by prepending `/<scope>`
from scope a stack.

The Router maintains a scope stack so that when the program flows you enter a
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

Extending the Router
--------------------

It is often useful to extend the `Router` class to provide specific
functionnalities in a container fashion.

[libesmtp](http://www.stafford.uklinux.net/libesmtp/) provide
[Vala bindings](http://valadoc.org/#!api=libesmtp/Smtp) and can be used to send
emails through the SMTP protocol.

```java
class MyApplication extends Router {

    public Smtp.Session smtp_session { get; default = Smtp.Session (); }

    public MyApplication () {
        base ();

        this.session.set_hostname ("mail.google.com:587");

        // send all messages after the request
        this.handler.connect_after ((req, res) => {
            session.start_session ();
        });
    }
}
