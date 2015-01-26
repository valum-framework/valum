Router
======

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
```
