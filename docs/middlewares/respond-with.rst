Respond
=======

The ``respond_with`` middleware provide a highly convenient way of defining
a response in term of a type instance.

It takes two arguments: a callback for responding given a :doc:`../vsgi/request`
and a callback for forwarding the returned value into an actual :doc:`../vsgi/response`
object.

For example, one could decide to implement endpoints that generate JSON
payloads, which would require serializing a :valadoc:`json-glib-1.0/Json.Node`.

::

    public HandlerCallback respond_with_json (RespondWithCallback<Json.Node> respond) {
        return respond_with<Json.Node> (respond, (req, res, next, ctx, node) => {
            res.expand_utf8 (Json.to_string (node));
        });
    }

Then, ``respond_with_json`` can be used as a handler callback:

::

    app.get ("/", respond_with_json (() => {
        var builder = new Json.Builder ();

        builder.begin_object ();
        builder.set_member_name ("data");
        builder.add_string_value ("Hello world!");
        builder.end_object ();

        return builder.get_root ();
    }));

This approach can be generalized for responding with serialized
:valadoc:`gobject-2.0/GLib.Object`.

