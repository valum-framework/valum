Valum web micro-framework
=========================

[![Build Status](https://travis-ci.org/valum-framework/valum.svg?branch=master)](https://travis-ci.org/valum-framework/valum)
[![Documentation Status](https://readthedocs.org/projects/valum-framework/badge/?version=latest)](https://readthedocs.org/projects/valum-framework/?badge=latest)
[![Coverage Status](https://coveralls.io/repos/valum-framework/valum/badge.svg?branch=master)](https://coveralls.io/r/valum-framework/valum?branch=master)
[![codecov.io](https://codecov.io/github/valum-framework/valum/coverage.svg?branch=master)](https://codecov.io/github/valum-framework/valum?branch=master)

Valum is a web micro-framework entirely written in the
[Vala](https://wiki.gnome.org/Projects/Vala) programming language.

```vala
using Valum;
using VSGI.Soup;

var app = new Router ();

app.get ("", (req, res) => {
    res.body.write_all ("Hello world!".data, null);
});

new Server ("org.valum.example.App", app.handle).run ();
```


Installation
------------

The installation process is fully documented in the
[user documentation](http://valum-framework.readthedocs.org/en/latest/installation.html).


Features
--------

 - asynchronous processing based on RAII and automated reference counting that
   just doesn't get in your way
 - powerful routing mechanism with scope, typed parameters and
   low-level utilities to write expressive web services
 - deploy anywhere with libsoup-2.4 built-in HTTP server, CGI, [FastCGI](http://www.fastcgi.com/drupal/) or SCGI
 - extensive documentation available at [valum-framework.readthedocs.org](http://valum-framework.readthedocs.org/en/latest)


Contributing
------------

Valum is built by the community under the [LGPL](https://www.gnu.org/licenses/lgpl.html)
license, so anyone can use or contribute to the framework.

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
