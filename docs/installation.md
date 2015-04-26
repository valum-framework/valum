## Dependencies

Valum has the following dependencies:

 - vala
 - glib-2.0    (>=2.32)
 - gio-2.0     (>=2.32)
 - libsoup-2.4 (>=2.38)
 - libgee-0.8  (>=0.6.4)
 - ctpl        (>=3.3)

Examples depend on

 - libmemcached
 - libluajit
 - memcached

We use the [waf build system](https://code.google.com/p/waf/) and distribute it
with the sources. All you need is a [Python interpreter](https://www.python.org/).

You can easily install the dependencies from a package manager.


### Debian and Ubuntu

```bash
apt-get install git-core build-essential python valac libglib2.0-dev \
                libsoup2.4-dev libgee-0.8-dev libfcgi-dev memcached \
                libmemcached-dev libluajit-5.1-dev libctpl-dev
```


### Fedora

```bash
yum install git python vala glib2-devel libsoup-devel libgee-devel fcgi-devel \
            memcached libmemcached-devel luajit-devel ctpl-devel
```


## Download the sources

You may either clone or download one of our
[releases](https://github.com/antono/valum/releases) from GitHub:

```bash
git clone git://github.com/antono/valum.git && cd valum
```


## Build

Build Valum and run the tests to make sure everything is fine.

```bash
./waf configure
./waf build && ./build/tests/tests
sudo ./waf install # only if you want the build files installed
```


## Run the sample application

You can run the sample application from the `build` folder, it uses the
[libsoup built-in HTTP server](https://developer.gnome.org/libsoup/stable/libsoup-server-howto.html)
and should run out of the box.

```bash
./build/example/app/app
```

Visit [http://localhost:3003](http://localhost:3003) on your favourite web
browser.
