memcached = dependency('libmemcached', required: false)
if memcached.found()
    executable('memcached', 'app.vala',
               dependencies: [glib, gobject, gio, soup, vsgi, vsgi_http, valum, memcached],
               vala_args: ['--vapidir=' + meson.current_source_dir() + '/vapi'])
endif
