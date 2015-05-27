VSGI
====

VSGI is a middleware that interfaces different web server technologies under a
common and simple set of abstractions.

For the moment, it is developed along with Valum to target the needs of a web
framework, but it will eventually be extracted and distributed as a shared
library.

It actually supports two technologies (libsoup-2.4 and FastCGI) and more
implementations are planned when the specification will be more stable.

.. toctree::

    request
    response
    converters
    server/index

VSGI produces process-based applications that are able to communicate with
various HTTP servers with protocols and process their client requests
asynchrously.

The entry point of a VSGI application is type-compatible with the
`ApplicationCallback` delegate. It is a function of two arguments:
a :doc:`request` and a :doc:`response`.

.. code:: vala

    using VSGI.Soup;

    new Server ((req, res) => {
        // process the request and produce the response...
    }).run ();
