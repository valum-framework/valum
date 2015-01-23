Basic features
--------------
These are necessary to get the framework usable with modern web requirements.

It's best to rely on libsoup features in order to minimize the work on
implementation and testing.

 - cookies using Soup.Cookie (arteymix)
 - session with Gee.Map and cookie
 - streamed bodies (arteymix)
 - FastCGI support (arteymix)
 - HTTP query using Soup.URL (arteymix)
 - x-www-form-urlencoded parsing using Soup.Form (arteymix)
 - documentation using valadoc

Router
------

 - register types at dynamic time using an Map
 - optional/nullable route parameter
 - regex literal in route declaration

View Engines
------------

 - Simple view engine based on [CTPL](http://ctpl.tuxfamily.org/). (antono)
 - Define View engine interface (antono)
 - JSON view engine. See [json generation in Vala](http://www.valadoc.org/Json-1.0/index.htm)
 - [CTPP2](http://ctpp.havoc.ru/en/) integration
   ([need patching](https://mail.gnome.org/archives/vala-list/2011-December/msg00022.html) CTPP2)
 - [Clearsilver](http://www.clearsilver.net/) integration
   (see [post](https://mail.gnome.org/archives/vala-list/2011-December/msg00019.html))

Server Adapters
---------------

 - migrate to [vsgi](http://github.com/antono/vsgi)

Dev tools
---------

 - Avahi support for mdns local
   addresses like http://cool-app.local
 - Logger with switchable backends (file, redis, dbus for ide integration).
 - Automagical configuration and build system for app
   develpers (autotools is too complex)
 - Integration with [Nemiver](http://projects.gnome.org/nemiver/)
 - Integration with [Perfkit](https://github.com/chergert/perfkit)
 - Integrate somehow with [Valgrind](https://live.gnome.org/Valgrind)

Storage engines
---------------

 - integrate [libgda](http://www.gnome-db.org/)
   (see [post](https://mail.gnome.org/archives/vala-list/2011-December/msg00015.html))
 - [U1DB](https://launchpad.net/shardbridge)
 - vapi for [mongo-glib](https://github.com/chergert/mongo-glib)
 - integrate
   [couchdb-glib](https://code.launchpad.net/~adiroiban/couchdb-glib/vala-bindings)
 - vapi for [hiredis](https://github.com/antirez/hiredis)
 - [charango](https://github.com/ssssam/charango) RDF storage via Tracker
 - [midgard2](http://new.midgard-project.org/) integration
 - [GObject Content Repository](https://github.com/midgardproject/GICR)

Scripting engines
-----------------

 - (lua) make luapanic safe for app
   (occurs in luajit under heavy load)
 - (scheme) vapi for [guile](http://www.gnu.org/software/guile/manual/html_node/Initialization.html#Initialization)
 - (javascript) integrate [javascriptcore](http://gitorious.org/seed-vapi) or [V8](https://github.com/crystalnix/vala-v8/blob/master/vala-test/vala_getting_started.vala) as (java)scripting engine. see valum/script/lua.vala for details
 - (ruby) try to make it working with ruby.vapi


Things to track
---------------

 - On migration of MainLoop to epoll
   - https://bugzilla.gnome.org/show_bug.cgi?id=156048
   - https://mail.gnome.org/archives/gtk-devel-list/2011-August/msg00059.html

Random links:
-------------

 * http://ctpl.tuxfamily.org/
 * https://github.com/apmasell/vapis/blob/master/fcgi.vapi
 * http://code.google.com/p/sqlheavy/wiki/UserGuide
 * https://gitorious.org/libpeas-vapi ?
 * https://github.com/apmasell/vapis
 * https://github.com/gorilla3d/Pawalicious/blob/master/server.vala
 * https://github.com/lgunsch/zmq-vala
 * https://github.com/fengy-research/libyaml-glib
