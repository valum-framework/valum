Static Resources Delivery
=========================

Middlewares are provided to ensure the delivery of static resources.

.. warning::

    The middlewares described in this document does not filter the path by
    which resources are accessed.

Resource bundle
---------------

.. code:: vala

    app.get ("<path:path>", Static.serve_from_path (File.new_for_uri ("public")));

