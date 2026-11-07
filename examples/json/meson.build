json_glib_dep = dependency('json-glib-1.0', required: false)
if json_glib_dep.found()
    executable('json', 'app.vala',
               dependencies: [glib_dep, gobject_dep, gio_dep, soup_dep, vsgi_dep, valum_dep, json_glib_dep])
else
    warning('This example will not be built: json-glib-1.0 is missing.')
endif
