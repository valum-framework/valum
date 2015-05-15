Response
========

Closing the response
--------------------

In GIO, streams are automatically closed when they get out of sight due
to reference counting. This is a particulary useful behiaviour for
asynchronous operations as references to requests or responses will
persist in a callback.

You do not have to close your streams (in general), but it can be a
useful to

-  avoid undesired read or write operation
-  release the stream if it's not involved in a expensive processing

This is a typical example where closing the response manually will have
a great incidence on the application throughput.

.. code:: vala

    app.get("", (req, res) => {
        res.write ("You should receive an email shortly...".data);
        res.close (); // you can even use close_async

        // send a success mail
        Mailer.send ("johndoe@example.com", "Had to close that stream mate!");
    });
