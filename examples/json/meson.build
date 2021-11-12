json = dependency('json-glib-1.0', required: false)
if json.found()
    executable('json', 'app.vala',
               dependencies: [glib, gobject, gio, soup, vsgi, valum_dep, json])
else
    warning('This example will not be built: json-glib-1.0 is missing.')
endif
