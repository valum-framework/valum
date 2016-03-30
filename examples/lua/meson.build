#if dependency('lua5.2', required: false).found()
#    lua = dependency('lua5.2')
#elif dependency('lua5.1', required: false).found()
#    lua = dependency('lua5.1')
#else
#    lua = dependency('lua')
#endif
#executable('lua', 'app.vala',
#           dependencies: [glib, gobject, gio, soup, vsgi, vsgi_http, valum, lua])
