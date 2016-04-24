template_glib = dependency('template-glib-1.0', required: false)
if template_glib.found()
    executable('template-glib', ['app.vala', gnome.compile_resources('template-glib-resources', 'app.gresource.xml', source_dir: '.')],
               dependencies: [glib, gobject, gio, soup, vsgi, valum, template_glib])
endif
