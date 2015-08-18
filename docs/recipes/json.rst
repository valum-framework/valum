JSON
====

JSON is a popular data format for web services and `json-glib`_ provide
a complete implementation that integrates with the GObject type system.

The following features will be covered in this document with code examples:

-   serialize a GObject
-   unserialize a GObject
-   parse an `GLib.InputStream`_ of JSON like a :doc:`../vsgi/request` body
-   generate JSON in a `GLib.OutputStream`_ like a :doc:`../vsgi/response` body

.. _json-glib: http://www.valadoc.org/#!wiki=json-glib-1.0/index
.. _GLib.InputStream: http://www.valadoc.org/#!api=gio-2.0/GLib.InputStream
.. _GLib.OutputStream: http://www.valadoc.org/#!api=gio-2.0/GLib.OutputStream

Produce and stream JSON
-----------------------

Using a `Json.Generator`_, you can conveniently produce an JSON object and
stream synchronously it in the :doc:`../vsgi/response` body.

.. _Json.Generator: http://www.valadoc.org/#!api=json-glib-1.0/Json.Generator

.. code:: vala

    app.get ("user/<username>", (req, res) => {
        var user      = new Json.Builder ();
        var generator = new Json.Generator ();

        user.set_member_name ("username");
        user.add_string_value (req.params["username"]);

        generator.root   = user.get_root ();
        generator.pretty = false;

        generator.to_stream (res.body);
    });

Serialize GObject
-----------------

You project is likely to have a model abstraction and serialization of GObject
with `Json.gobject_serialize`_ is a handy feature. It will recursively build
a JSON object from the encountered properties.

.. _Json.gobject_serialize: http://www.valadoc.org/#!api=json-glib-1.0/Json.gobject_serialize

.. code:: vala

    public class User : Object {
        public string username { construct; get; }

        public User.from_username (string username) {
            // populate the model from the data storage...
        }

        public void update () {
            // persist the model in data storage...
        }
    }

.. code:: vala

    app.get ("user/<username>", (req, res) => {
        var user      = new User.from_username (req.params["username"]);
        var generator = new Json.Generator ();

        generator.root   = Json.gobject_serialize (user);
        generator.pretty = false;

        generator.to_stream (res.body);
    });

With middlewares, you can split the process in multiple reusable steps to avoid
code duplication. They are described in the :doc:`../router` document.

-  fetch a model from a data storage
-  process the model with data obtained from a `Json.Parser`_
-  produce a JSON response with `Json.gobject_serialize`_

.. _Json.Parser: http://www.valadoc.org/#!api=json-glib-1.0/Json.Parser
.. _Json.gobject_serialize: http://www.valadoc.org/#!api=json-glib-1.0/Json.gobject_serialize

.. code:: vala

    app.scope ("user", (user) => {
        // fetch the user
        app.get ("<username>", (req, res, next, stack) => {
            stack.push_tail (new User.from_username (req.params["username"]));
            next (req, res);
        });

        // update model data
        app.post ("<username>", (req, res, next, stack) => {
            var username = stack.pop_tail ().get_string ();
            var user     = new User.from_username (username);
            var parser   = new Json.Parser ();

            // whitelist for allowed properties
            string[] allowed = {"username"};

            // update the model when members are read
            parser.object_member.connect ((obj, member) => {
                if (member in allowed)
                    user.set_property (member,
                                       obj.get_member (member).get_value ());
            });

            if (!parser.load_from_stream (req.body))
                throw new ClientError.BAD_REQUEST ("unable to parse the request body");

            // persist the changes
            user.update ();

            if (user.username != username) {
                // model location has changed, so we throw a 201 CREATED status
                throw new Success.CREATED ("/user/%s".printf (user.username));
            }

            stack.push_tail (user);

            next (req, res);
        });

        // serialize to JSON any provided GObject
        app.all (null, (req, res, next, stack) => {
            var generator = new Json.Generator ();

            generator.root   = Json.gobject_serialize (stack.pop_tail ().get_object ());
            generator.pretty = false;

            res.headers.set_content_type ("application/json", null);

            generator.to_stream (res.body);
        });
    });

It is also possible to use `Json.Parser.load_from_stream_async`_ and invoke
`next` in the callback with :doc:`../router` ``invoke`` function if you are
expecting a considerable user input.

.. _Json.Parser.load_from_stream_async: http://www.valadoc.org/#!api=json-glib-1.0/Json.Parser.load_from_stream_async

.. code:: vala

    parser.load_from_stream_async.begin (req.body, null, (obj, result) => {
        var success = parser.load_from_stream_async.end (result);

        user.update ();

        stack.push_tail (user);

        // execute 'next' in app context
        app.invoke (req, res, next);
    });

