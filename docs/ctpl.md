Valum provides
[CTPL](http://ctpl.tuxfamily.org/doc/unstable/ctpl-CtplEnviron.html) as a view
engine.

Three primitive types and one composite type are supported:

 - `int`
 - `float`
 - `string`
 - `array` of preceeding types (but not of `array`)

Creating views
--------------

The `View` class provides constructors to create views from `string`, file path
and `InputStream`.

```java
var template = new View.from_string ("{a}");
```

```java
var template = new View.from_path ("path/to/your/template.tpl");
```

It is a good practice to bundle static data in the executable using
[GLib.Resource](http://valadoc.org/#!api=gio-2.0/GLib.Resource).
```java
var template = new View.from_stream (resources_open_stream ("/your/template.tpl"));
```

Environment
-----------

A `View` instance provides an `Ctpl.Environ` environment from which you can push
and pop variables. CTPL environment operations are fully documented at
[ctpl.tuxfamily.org](http://ctpl.tuxfamily.org/doc/unstable/ctpl-CtplEnviron.html).

```java
var template = new View.from_string ("{a}");

template.environment.push_int ("a", 1);
```

Valum provides helpers for dumping `GLib.HashTable`, `Gee.Collection`, `Gee.Map`
and `Gee.MultiMap` as well as array of `double`, `long` and `string`.

```
double[] dbs = {8.2, 12.3, 2};

template.push_string ("key", "value");
template.push_doubles ("key", dbs);
```

`HashTable`, `Map` and `MultiMap` are pushed by pushing all their entries
ony-by-one.  Generated environment keys are the simple concatenation of the
providen key, a underscore (`_`) and the entry key.

```java
var map = new HashMap<string, string> ();

map["key"] = "value";
map["key2"] = "value2";

template.push_map ("map", map); // map_key and map_key2 will be pushed
```

Streaming views
---------------

The best way of rendering a view is by streaming it directly into a `Response`
instance with the `splice` function. This way, your application can produce very
big output efficiently.

```java
app.get ("", (req, res) => {
    var template = new View.from_string ("");
    template.splice (res);
});
```
