Caching
=======

GLruCache
---------

For basic caching requirements, `GLruCache`_ provide a really simple yet
powerful implementation of a LRU cache with a useful features:

-   eviction of arbitrary keys
-   fast non-atomic fetch mode

.. _glrucache: https://github.com/chergert/glrucache

::

    using GLru;

    var cache = new Cache<string, string> (str_hash, str_equal, x => x + x);

    cache.max_size = 512; // number of items to keep

    var val = cache["key"];

