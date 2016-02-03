Server-Sent Events
==================

Valum provides a middleware for the HTML5 `Server-Sent Events`_ protocol to
stream notifications over a persistent connection.

.. _Server-Sent Events: http://www.w3.org/TR/eventsource/

The ``ServerSentEvents.stream_events`` function creates a handling middleware
and provide a ``send`` callback to transmit the actual events.

.. code-block:: vala

    using Valum;
    using Valum.ServerSentEvents;

    app.get ("sse", stream_events ((req, send) => {
        send (null, "some data");
    }));

.. code-block:: javascript

    var eventSource = new EventSource ("/sse");

    eventSource.onmessage = function(message) {
        console.log (message.data); // displays 'some data'
    };

Multi-line messages
-------------------

Multi-line messages are handled correctly by splitting the data into into
multiple ``data:`` chunks.

.. code-block:: vala

    send (null, "some\ndata");

::

    data: some
    data: data

