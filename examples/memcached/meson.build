memcached_dep = dependency('libmemcached', required: false)
if memcached_dep.found()
    executable('memcached', 'app.vala',
               dependencies: [glib_dep, gobject_dep, gio_dep, soup_dep, vsgi_dep, valum_dep, memcached_dep],
               vala_args: ['--vapidir=' + meson.current_source_dir() + '/vapi'])
endif
