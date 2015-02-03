GLib provides an [resource api](http://valadoc.org/#!api=gio-2.0/GLib.Resource)
for bundling static resources and link them in the executable.

An efficient approach to serve static content with Valum is to link and stream.

It has a few advantages:

 - content is compiled with the executable or bundled separately, so it loads
   lightning fast
 - resource api is simpler than file api
 - application do not have to deal with resource location or minimally if a
   separate bundle is used

This only applies to small and static resources as it will grow the size of the
executable. If you have to change your resources at runtime, it will require an
additionnal compilation step.

# Integration

Let's say your project has a few resources:

 * CTPL templates in a `templates` folder
 * CSS, JavaScript files in `static` folder

Setup a `app.gresource.xml` file that defines what resources will to be bundled.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<gresources>
  <gresource>
    <file>templates/home.html</file>
    <file>templates/404.html</file>
    <file>static/css/bootstrap.min.css</file>
  </gresource>
</gresources>
```

You can test your setup with:

```bash
glib-compile-resource app.gresource.xml
```

Latest version of `waf` automatically link `*.gresource.xml` if you load the
`glib2` plugin and add the file to your sources.

```python
bld.load('glib2')

bld.program(
   packages  = ['glib-2.0', 'libsoup-2.4', 'gee-0.8', 'ctpl', 'lua', 'libmemcached'],
   target    = 'app',
   use       = 'valum',
   source    = bld.path.ant_glob('**/*.vala') + ['app.gresource.xml'],
   uselib    = ['GLIB', 'CTPL', 'GEE', 'SOUP', 'LUA', 'MEMCACHED'],
   vapi_dirs = ['../../vapi', 'vapi'])
```

The sample application example serve its static resources this way if you need
a more concrete example.
