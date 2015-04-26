Assuming that Valum is [built and installed](installation.md) correctly, you
are ready to create your first application!

Valum is not designed to be installed as a shared library (at least for now),
but more like a set of build files and tools helps one develop a web
application.

You can install the build files with `waf`, it will simplify the building
process:

```bash
sudo ./waf install
```


## Simple 'Hello world!' application

You can use this sample application and project structure as a basis. The full
code is [available on GitHub](https://github.com/valum-framework/example).

```javascript
using Valum;
using VSGI;

var app = new Router ();

app.get("", (req, res) => {
    var writer = new DataOutputStream (res);
    writer.put_string ("Hello world!");
});

new SoupServer (app, 3003).run ();
```

```
build/
src/
    app.vala
vapi/
    ctpl.vala
    fcgi.vala
```


### VAPI bindings

[CTPL](ctpl.tuxfamily.org) and [FastCGI](http://www.fastcgi.com/drupal/) are
not providing Vala bindings, so you need to copy them in your project `vapi`
folder. You can find them in the
[vapi folder of Valum](https://github.com/antono/valum/tree/master/vapi).

You can also find more VAPIs in
[nemequ/vala-extra-vapis](https://github.com/nemequ/vala-extra-vapis) GitHub
repository.

Unless you installed Valum with `--prefix=/usr`, you have to export `pkg-config`
search path:

```bash
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig

# generate the c sources
valac --vapidir=vapi --pkg valum-0.1 --pkg libsoup-2.4 --pkg gee-0.8 \
                     --pkg ctpl --pkg fcgi \
      --ccode src/app.vala

# compile and link against libvalum
gcc $(pkg-config valum-0.1 --cflags --libs) -o build/app \
    src/app.c /usr/local/lib/libvalum-0.1.a

# run the generated binary
./build/app
```


### Using a build tool (waf)

It is preferable to use a build system like
[waf](https://code.google.com/p/waf/) to automate all this process. Get
a release of `waf` and copy this file under the name `wscript` at the root of
your project.

```python
#!/usr/bin/env python

def options(cfg):
    cfg.load('compiler_c')

def configure(cfg):
    cfg.load('compiler_c vala')
    cfg.check_cfg(package='valum-0.1', uselib_store='VALUM', args='--libs --cflags')

def build(bld):
    bld.load('vala')
    bld.program(
        packages = ['valum-0.1'],
        target    = 'app',
        source    = 'src/app.vala',
        uselib    = ['VALUM'],
        vapi_dirs = ['vapi'],
        stlib     = ['valum-0.1'])
```

You should now be able to build by issuing the following commands:

```bash
./waf configure
./waf build
```
