Persistency
===========

Memcached
---------

.. code:: vala

    var mc = new Valum.NoSQL.Memcached();

    // GET /hello
    app.get("hello", (req, res) => {
      var value = mc.get("hello");
      res.append(value);
      mc.set("hello", @"Updated $value");
    });

Redis (TODO)
------------

We need vapi for hiredis: https://github.com/antirez/hiredis

.. code:: vala

    var redis = new Valum.NoSQL.Redis();

    app.get("hello", (req, res) => {
      var value = redis.get("hello");
      res.append(value);
      redis.set("hello", @"Updated $value");
    });

MongoDB (TODO)
--------------

This is not yet implemented. But mongo client for vala is on the way:
https://github.com/chergert/mongo-glib

.. code:: vala

    var mongo = new Valum.NoSQL.Mongo();

    // GET /hello.json
    app.get("hello.json", (req, res) => {
      res.mime = "application/json";
      res.append(mongo.find("hello"));
    });
