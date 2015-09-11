Server-Sent Events
==================

Valum provides a middleware for the HTML5 `Server-Sent Events`_ protocol to
stream notifications over a persistent connection.

.. _Server-Sent Events: http://www.w3.org/TR/eventsource/

The ``ServerSentEvents.context`` function create a handling middleware and
provide a ``send`` callback to transmit the actual events.

.. code-block:: vala

    using Valum;

    app.get ("sse", ServerSentEvents.context ((req, send) => {
        send (null, "some data");
    }));

.. code-block:: javascript

    var eventSource = new EventSource ("/sse");

    eventSource.onmessage = function(data) {
        console.log ("some data"); // displays 'some data'
    };

Multi-line messages are handled correctly by sending multiple ``data:`` chunks.

.. code-block:: vala

    send (null, "some\ndata");

::

    data: some
    data: data

