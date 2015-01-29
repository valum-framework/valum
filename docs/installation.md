Dependencies
------------

Valum has the following dependencies:

 - vala
 - glib-2.0
 - libsoup-2.4
 - libgee-0.8
 - ctpl

The sample application depends on

 - libmemcached
 - libluajit
 - memcached

We use the [waf build system](https://code.google.com/p/waf/) and distribute it
with the sources, so you will need a
[Python interpreter](https://www.python.org/).

Debian and Ubuntu
-----------------

```bash
apt-get install git-core build-essential python valac libglib2.0-dev \
                libsoup2.4-dev libgee-0.8-dev libfcgi-dev memcached \
                libmemcached-dev libluajit-5.1-dev libctpl-dev
```

Fedora
------

```bash
yum install git python vala glib2-devel libsoup-devel libgee-devel fcgi-devel \
            memcached libmemcached-devel luajit-devel libctpl-devel
```

Download the sources
--------------------

You may either clone or download one of our
[releases](https://github.com/antono/valum/releases) from GitHub
```bash
git clone git://github.com/antono/valum.git && cd valum
```

Build
-----

Build Valum and run the tests to make sure everything is fine.

```bash
./waf configure
./waf build && ./build/tests/tests
```

Run the sample application
--------------------------

You can run the sample application from the `build` folder, it uses the libsoup
built-in HTTP server.

```bash
./build/example/app/app
```

Visit [http://localhost:3003](http://localhost:3003) on your favourite web
browser.
