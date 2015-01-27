Modular application
===================

It is often useful to construct an application as a set of independant modules
for decoupling the code or distributing reusable pieces.

Let's say you need an administration section:

```java
using Valum;

public static void admin_loader (Router admin) {
    admin.get ("", (req, res) => {
        // ...
    });
}
```

Then you can easily load your module into a concrete one:

```java
using Valum;

var app = new Router ();

app.scope ("admin", (admin) => {
    // scoped in /admin so we have the /admin/ route declared
    admin_loader (admin);
});
```

If you distribute your code, use namespaces to avoid conflicts:

```java
using Valum;

namespace Admin {
    public static void admin_loader (Router admin) {
        admin.get ("", (req, res) => {
            // ...
        });
    }
}
```
