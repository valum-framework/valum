Represents an incoming request to your application to which you have to provide
a [response](vsgi/response).

This is part of VSGI, a middleware upon which Valum is built.

HTTP method
-----------

The Request class provides constants for the following HTTP methods:

 - `OPTIONS`
 - `GET`
 - `HEAD`
 - `POST`
 - `PUT`
 - `DELETE`
 - `TRACE`
 - `CONNECT`
 - `PATCH`

Additionnaly, an array of HTTP methods `Request.METHODS` is providen to list all
supported HTTP methods by VSGI.

These can be conveniently used in low-level `Router` functions to avoid using
plain strings to describe standard HTTP methods.

```java
app.method (Request.GET, "", (req, res) => {
    // ...
});
```

Request parameters
------------------

As a facility to parametrize a `Request` instance, a `HashTable<string, string>`
of parameters is providen by the request.

In Valum, this hashtable will contain extracted captures with their respectives
value from a [rule](route#rules) or a
[regular expression](route#plumbering-with-regular-expression).

It is defaulted to `null` until a [matcher](route#plumbering-with-route)
populates it.

```java
app.get ("<int:i>", (req, res) => {
    var i = req.params["i"];
});
```

Query
-----

A pre-parsed query is available from a Request instance according to the
`application/x-www-form-urlencoded` specification.

`null` means that the query is not present in the URI.

 - `/uri/?` the query will be an empty `HashTable`
 - `/uri/`  the query will be `null`

If you would like to use a parsing of your own, you can sill access the raw
query via the `Request.uri.get_query` function.

HTTP session
------------

Session handling is providen by multiple HTTP server implementation, so the
Request defines a session with basic operations to create, update and delete
session.

The absence of session is represented by `null`. Unless you know the session is
set, you should always null-check it. A good practise is to provide such
facilities by extending the Router.

Session are generally not implememented using a `HashTable` internally, but
rather through specific server communication. The HashTable you get from the
session property is created on the fly. This allow session operation to be
transactionnal.

```
app.get ("", (req, res) => {
    // create if missing
    if (req.session == null)
        req.session = new HashTable<string, string> ();

    // edit a copy
    var session = req.session;
    session["key"] = "value";

    // save your changes
    req.session = session;
});
```
