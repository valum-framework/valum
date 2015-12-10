Subdomain
=========

The ``subdomain`` middleware matches :doc:`../vsgi/request` which subdomain is conform to
expectations.

.. note::

    Domains are interpreted in their semantical right-to-left order and matched
    as suffix.

The pattern is specified as the first argument. It may contain asterisk ``*``
which specify that any supplied label satisfy that position.

.. code:: vala

    app.get (subdomain ("api"), (req, res) => {
        // match every request from 'api.*.*'
    });

    app.get (subdomain ("*.*.user"), (req, res) => {
        // match any '*.*.user'
    });

This middleware can be used along with subrouting to mount any :doc:`../router`
on a specific domain pattern.

.. code:: vala

    var app = new Router ();
    var api = new Router ();

    app.matcher (subdomain ("api"), api.handle);

Strict
------

There is two matching mode: loose and strict. The loose mode only expect the
request to be performed on a suffix-compatible hostname. For instance, ``api``
would match ``api.example.com`` and ``v1.api.example.com`` as well.

To prevent this and perform a _strict_ match, simply specify the second
argument. The domain of the request will have to supply exactly the same amount
of labels matching the expectations.

.. code:: vala

    app.get (subdomain ("api", true), (req, res) => {
        // match every request exactly from 'api.*.*'
    });

Skip labels
-----------

By default, the two first labels are ignored since web applications are
typically served under two domain levels (eg. example.com). If it's not the
case, the number of skipped labels can be set to any desirable value.

.. code:: vala

    app.get (subdomain ("api.example.com", true, 0), (req, res) => {
        // match every request from 'api.example.com'
    });

