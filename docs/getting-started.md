
Assuming Valum is [installed correctly](), you are ready to create your first
application!

First of all, you have to install Valum:

```bash
sudo ./waf install
```

You can use this sample application as a basis; just save the code in a file
named `app.vala`.

```javascript
using Valum;
using VSGI;

var app = new Router ();

app.get("", (req, res) => {
    var writer = new DataOutputStream (res);
    writer.put_string ("Hello world!");
});

new SoupServer (app, 3003).listen ();
```

Right now, CTPL and libfcgi are not providing Vala bindings, so you need to copy
them in your project `vapi` folder. You can find them in the
[vapi folder of Valum]().

Unless you installed Valum with `--prefix=/usr`, you have to export `pkg-config`
search path:

```bash
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
```

You now have everything you need to build your own application:

```bash
valac --vapidir=vapi --pkg valum-0.1 --pkg ctpl --pkg fcgi --ccode app.vala
gcc $(pkg-config valum-0.1 --cflags --libs) app.c /usr/local/lib/libvalum-0.1.a -o app
./app
```

It is preferable to use a build system like
[waf](https://code.google.com/p/waf/) to automate all this process.
