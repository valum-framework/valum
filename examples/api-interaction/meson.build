json_dep = dependency('json-glib-1.0', required: false)
if json_dep.found()
    executable('api-interaction', 'app.vala',
               dependencies: [glib_dep, gobject_dep, gio_dep, soup_dep, vsgi_dep, valum_dep, json_dep])
endif
