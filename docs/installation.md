Dependencies
------------

Valum has the following dependencies:

 - vala
 - glib-2.0
 - libsoup-2.5
 - libgee-0.8
 - ctpl

The sample application depends on

 - libmemcached
 - libluajit
 - memcached

We use the [waf build system](https://code.google.com/p/waf/) and distribute it
with the sources, so you will need Python.

Debian and Ubuntu
-----------------

```bash
apt-get install -y git-core build-essential python valac libgee-0.8-dev \
                   libsoup2.4-dev memcached libmemcached-dev libluajit-5.1-dev \
                   libctpl-dev
```

Fedora
------

```bash
yum install git python vala libgee-devel libsoup-devel libctpl-devel \
            memcached libmemcached-devel luajit-devel
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

We use the waf build system, so all you need is Python installed
```bash
./waf configure
./waf build
```

Run the sample application
--------------------------

You can run the sample application from the `build` folder, it uses the libsoup
built-in HTTP server.

```bash
./build/valum
```

Visit [http://localhost:3003](http://localhost:3003) on your favourite web
browser.
