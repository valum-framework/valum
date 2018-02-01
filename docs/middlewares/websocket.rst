WebSocket
=========

.. versionadded:: 0.4

Valum support WebSocket via :valadoc:`libsoup-2.4/Soup.WebsocketConnection`
implementation if libsoup-2.4 (>=2.50) is installed.

.. note::

    Not all server protocols support WebSocket. It is at least guaranteed to
    work with the :doc:`../vsgi/server/http` server and for other, it should only a matter of
    implementation.

The ``websocket`` middleware can be used in the context of a ``GET`` method. It
will perform the handshake and promote the underlying :doc:`../vsgi/connection`
to perform WebSocket message exchanges.

The first argument is a list of supported protocols, which can be left empty.
The second argument is a forward callback that will receive the WebSocket
connection.

::

    app.get ("/", websocket ({}, (req, res, next, ctx, ws) => {
        ws.send_text ();
        return true;
    }));

Since the middleware actually *steal* the connection, body streams are rendered
useless and futher communications should be done exclusively via the WebSocket
connection.

