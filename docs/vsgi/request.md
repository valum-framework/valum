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
