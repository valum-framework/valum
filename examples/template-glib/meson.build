template_glib = dependency('template-glib-1.0', required: false)
if template_glib.found()
    executable('template-glib', ['app.vala', gnome.compile_resources('template-glib-resources', 'app.gresource.xml', source_dir: '.')],
               dependencies: [glib, gobject, gio, soup, vsgi, valum_dep, template_glib])
else
    warning('This example will not be built: template-glib-1.0 is missing.')
endif
