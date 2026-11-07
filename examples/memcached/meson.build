libmemcached_dep = dependency('libmemcached', required: false)
if libmemcached_dep.found()
    executable('memcached', 'app.vala',
               dependencies: [glib_dep, gobject_dep, gio_dep, soup_dep, vsgi_dep, valum_dep, libmemcached_dep],
               vala_args: ['--vapidir=' + meson.current_source_dir() + '/vapi'])
else
    warning('This example will not be built: libmemcached is missing.')
endif
