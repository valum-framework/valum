libmarkdown_dep = meson.get_compiler('c').find_library('markdown', required: false)
if libmarkdown_dep.found()
    executable('markdown', 'app.vala',
               dependencies: [glib_dep, gobject_dep, gio_dep, soup_dep, vsgi_dep, valum_dep, libmarkdown_dep],
               vala_args: ['--pkg=libmarkdown', '--vapidir=' + meson.current_source_dir() + '/vapi'])
else
    warning('This example will not be built: libmarkdown is missing.')
endif
