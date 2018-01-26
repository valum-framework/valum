memcached = dependency('libmemcached', required: false)
if memcached.found()
    executable('memcached', 'app.vala',
               dependencies: [glib, gobject, gio, soup, vsgi, valum_dep, memcached],
               vala_args: ['--vapidir=' + meson.current_source_dir() + '/vapi'])
endif
