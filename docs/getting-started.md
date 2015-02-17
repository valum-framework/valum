Assuming that Valum is [built and installed](installation.md) correctly, you
are ready to create your first application!

You can use this sample application and project structure as a basis.

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

[CTPL](ctpl.tuxfamily.org) and [FastCGI](http://www.fastcgi.com/drupal/) are
not providing Vala bindings, so you need to copy them in your project `vapi`
folder. You can find them in the
[vapi folder of Valum](https://github.com/antono/valum/tree/master/vapi).

Unless you installed Valum with `--prefix=/usr`, you have to export `pkg-config`
search path:

```bash
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig

valac --vapidir=vapi --pkg valum-0.1 --pkg libsoup-2.4 --pkg gee-0.8 \
                     --pkg ctpl --pkg fcgi \
      --ccode src/app.vala

gcc $(pkg-config valum-0.1 --cflags --libs) -o build/app \
    src/app.c /usr/local/lib/libvalum-0.1.a

./build/app
```

It is preferable to use a build system like
[waf](https://code.google.com/p/waf/) to automate all this process.
