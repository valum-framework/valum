Valum micro-framework
=====================

[![Build Status](https://travis-ci.org/antono/valum.svg)](https://travis-ci.org/antono/valum)

Valum is a web micro-framework entirely written in the
[Vala](https://wiki.gnome.org/Projects/Vala) programming language.

Features
--------

Valum is built upon libsoup and provides a minimal set of features that covers
just enough of the HTTP protocol to suit any requirement:

 - router with scope, typed parameters and low-level utilities
 - simple Request-Response mechanism via callback
 - cookies and session handling
 - complete integration of the [FastCGI](http://www.fastcgi.com/drupal/)
   protocol
 - [CTPL](http://ctpl.tuxfamily.org/), a simple templating engine
 - extensive documentation available at
   [valum.readthedocs.org](http://valum.readthedocs.org/en/latest)

If you need more horsepower, bindings exist for

 - HTTP protocol elements with
   [libsoup](https://wiki.gnome.org/action/show/Projects/libsoup)
 - database abstraction via [GDA](http://www.gnome-db.org/Home)
 - cryptography and password hashing with
   [gcrypt](http://www.gnu.org/software/libgcrypt/)
 - more bindings on
   [GNOME wiki](https://wiki.gnome.org/Projects/Vala/ExternalBindings) and
   [nemequ/vala-extra-vapis](https://github.com/nemequ/vala-extra-vapis)

Contributing
------------

Valum is built by the community, so anyone can contribute.

 1. fork repository
 2. pick one task from TODO.md or [GitHub issues](https://github.com/antono/valum/issues)
 3. let us know what you will do (or attempt!)
 4. code
 5. make a pull request of your amazing changes
 6. let everyone enjoy :)

We use [semantic versionning](http://semver.org/), so make sure that your
changes

 * does not alter api in bugfix release
 * does not break api in minor release
 * breaks api in major (we like it that way!)

Discussions and help
--------------------

You can get help with Valum from different sources:

 - mailing list: [vala-list](https://mail.gnome.org/mailman/listinfo/vala-list).
 - IRC channel: #vala at irc.gimp.net
 - [Google+ page for Vala](https://plus.google.com/115393489934129239313/)
 - issues on [GitHub](https://github.com/antono/valum/issues) with the
   `question` label


