json = dependency('json-glib-1.0', required: false)
if json.found()
    executable('json', 'app.vala',
               dependencies: [glib, gobject, gio, soup, vsgi, valum_dep, json])
endif
