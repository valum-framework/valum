# Valum Web micro-framework

[![Build Status](https://github.com/valum-framework/valum/actions/workflows/main.yml/badge.svg?branch=master)](https://github.com/valum-framework/valum/actions/workflows/main.yml)
[![Documentation Status](https://readthedocs.org/projects/valum-framework/badge/?version=latest)](https://readthedocs.org/projects/valum-framework/?badge=latest)
[![codecov.io](https://codecov.io/github/valum-framework/valum/coverage.svg?branch=master)](https://codecov.io/github/valum-framework/valum?branch=master)

Valum is a Web micro-framework entirely written in the
[Vala](https://wiki.gnome.org/Projects/Vala) programming language.

```vala
using Valum;
using VSGI;

var app = new Router ();

app.use (basic ()); /* handle stuff like 404 errors and more */

app.get ("/", (req, res) => {
    res.headers.set_content_type ("text/plain", null);
    return res.expand_utf8 ("Hello world!");
});

Server.@new ("http", handler: app).run ({"app", "--address=0.0.0.0:3003", "--forks=4"});
```


## Installation

### Docker

We maintain [Docker images](https://hub.docker.com/r/valum/valum/) already setup with Valum and the latest LTS version of Ubuntu.

```
docker pull valum/valum
```

### Bower

If you use [Meson](http://mesonbuild.com/), you can install Valum as a subproject using [Bower](https://bower.io/):

```
bower install valum
```

For other installation procedures, head to the [user documentation](http://valum-framework.readthedocs.org/en/latest/installation.html).

## Features

Valum has a two layer architecture: VSGI a middleware that abstract away various network protocols under a simple interface and Valum itself, a Web micro-framework that provide all the features needed for writing applications and services. In short it provides:

 - powerful routing mechanism to write expressive Web services:
    - helpers and flags (i.e. `Method.GET | Method.POST`) for common HTTP methods
    - scoping
    - rule system supporting typed parameters, group, optional and wildcard
    - regular expression with capture extraction
    - automatic `HEAD` and `OPTIONS`
    - subrouting
    - status codes through error domains (i.e. `throw new Redirection.PERMANENT ("http://example.com/");`
    - context to hold states
 - middlewares for subdomains, server-sent events, content negotiation and much more
 - VSGI, an abstraction layer for various protocols:
     - fast, asynchronous and elegant
     - streaming-first API
     - listen on multiple interfaces (e.g. port, UNIX socket, file descriptor)
       with tight [GIO](https://developer.gnome.org/gio/stable/) integration
     - support [libsoup-2.4 built-in HTTP server](https://wiki.gnome.org/Projects/libsoup), CGI,
       [FastCGI](http://www.fastcgi.com/drupal/) and [SCGI](https://python.ca/scgi/) out of the box
     - support plugin for custom server implementation
     - `fork` to scale on multi-core architecture
     - cushion for parsing CLI, logging and running a Web application
 - extensive documentation at [valum-framework.readthedocs.io](https://valum-framework.readthedocs.io/en/latest/)


## Contributing

Valum is built by the community under the [LGPL](https://www.gnu.org/licenses/lgpl.html)
license, so anyone can use or contribute to the framework.

 1. fork repository
 2. pick one task from TODO.md or [GitHub issues](https://github.com/valum-framework/valum/issues)
 3. let us know what you will do (or attempt!)
 4. code
 5. make a pull request of your amazing changes
 6. let everyone enjoy :)

We use [semantic versioning](http://semver.org/), so make sure that your
changes

 * does not alter api in bugfix release
 * does not break api in minor release
 * breaks api in major (we like it that way!)


# Discussions and help

You can get help with Valum from different sources:

 - mailing list: [vala-list](https://mail.gnome.org/mailman/listinfo/vala-list).
 - IRC channel: #vala and #valum at irc.gimp.net
 - issues on [GitHub](https://github.com/valum-framework/valum/issues) with the
   `question` label
