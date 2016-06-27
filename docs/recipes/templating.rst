Templating
==========

Template engines are very important tools to craft Web applications and a few
libraries exist to handle that tedious work.

Compose
-------

For HTML5, `Compose`_ is quite appropriate.

.. _Compose: https://github.com/arteymix/compose

::

    app.get ("/", (req, res) => {
        return res.expand_utf8 (
            html ({},
                head ({},
                    title ()),
                body ({},
                    section (
                        h1 ({}, "Section Title")))));
    });

It comes with two utilities: ``take`` and ``when`` to iterate and perform
conditional evaluation.

::

    var users = Users.all ();

    take<User> (()     => { return users.next (); },
                (user) => { return user.username; });

    when (User.current ().is_admin,
          () => { return p ({}, "admin") },
          () => { return p ({}, "user") });

Strings are not escaped by default due to the design of the library. Instead,
all unsafe value must be escaped properly. For HTML, ``e`` is provided.

::

    e (user.biography);

Templates and fragments can be store in Vala source files to separate concerns.
In this case, arguments would be used to pass the environment.

::

    using Compose.HTML5;

    namespace Project.Templates
    {
        public string page (string title, string content)
        {
            return
                div ({"id=%s".printf (title)},
                    h2 ({}, e (title)),
                    content);
        }
    }

