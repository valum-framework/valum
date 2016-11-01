JSON
====

JSON is a popular data format for Web services and :valadoc:`json-glib-1.0/Json`
provide a complete implementation that integrates with the GObject type system.

The following features will be covered in this document with code examples:

-   serialize a GObject
-   unserialize a GObject
-   parse an :valadoc:`gio-2.0/GLib.InputStream` of JSON like a :doc:`../vsgi/request` body
-   generate JSON in a :valadoc:`gio-2.0/GLib.OutputStream` like a :doc:`../vsgi/response` body

Produce and stream JSON
-----------------------

Using a :valadoc:`json-glib-1.0/Json.Generator`, you can conveniently produce
an JSON object and stream synchronously it in the :doc:`../vsgi/response` body.

::

    app.get ("/user/<username>", (req, res) => {
        var user      = new Json.Builder ();
        var generator = new Json.Generator ();

        user.set_member_name ("username");
        user.add_string_value (req.params["username"]);

        generator.root   = user.get_root ();
        generator.pretty = false;

        return generator.to_stream (res.body);
    });

Serialize GObject
-----------------

You project is likely to have a model abstraction and serialization of GObject
with :valadoc:`json-glib-1.0/Json.gobject_serialize` is a handy feature. It
will recursively build a JSON object from the encountered properties.

::

    public class User : Object {
        public string username { construct; get; }

        public User.from_username (string username) {
            // populate the model from the data storage...
        }

        public void update () {
            // persist the model in data storage...
        }
    }

::

    app.get ("/user/<username>", (req, res) => {
        var user      = new User.from_username (req.params["username"]);
        var generator = new Json.Generator ();

        generator.root   = Json.gobject_serialize (user);
        generator.pretty = false;

        return generator.to_stream (res.body);
    });

With middlewares, you can split the process in multiple reusable steps to avoid
code duplication. They are described in the :doc:`../router` document.

-  fetch a model from a data storage
-  process the model with data obtained from a :valadoc:`json-glib-1.0/Json.Parser`
-  produce a JSON response with :valadoc:`json-glib-1.0/Json.gobject_serialize`

::

    app.scope ("/user", (user) => {
        // fetch the user
        app.rule (Method.GET | Method.POST, "/<username>", (req, res, next, context) => {
            var user = new User.from_username (context["username"].get_string ());

            if (!user.exists ()) {
                throw new ClientError.NOT_FOUND ("no such user '%s'", context["username"]);
            }

            context["user"] = user;
            return next ();
        });

        // update model data
        app.post ("/<username>", (req, res, next, context) => {
            var username = context["username"].get_string ();
            var user     = context["user"] as User;
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

            context["user"] = user;

            return next ();
        });

        // serialize to JSON any provided GObject
        app.rule (Method.GET, "*", (req, res, next, context) => {
            var generator = new Json.Generator ();

            generator.root   = Json.gobject_serialize (context["user"].get_object ());
            generator.pretty = false;

            res.headers.set_content_type ("application/json", null);

            return generator.to_stream (res.body);
        });
    });

It is also possible to use :valadoc:`json-glib-1.0/Json.Parser.load_from_stream_async`
and invoke `next` in the callback with :doc:`../router` ``invoke`` function if
you are expecting a considerable user input.

::

    parser.load_from_stream_async.begin (req.body, null, (obj, result) => {
        var success = parser.load_from_stream_async.end (result);

        user.update ();

        context["user"] = user;

        // execute 'next' in app context
        return app.invoke (req, res, next);
    });

