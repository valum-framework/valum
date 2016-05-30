json = dependency('json-glib-1.0', required: false)
if json.found()
    executable('json', 'app.vala',
               dependencies: [glib, gobject, gio, soup, vsgi, vsgi_http, valum, json])
endif
