markdown_dep = meson.get_compiler('c').find_library('markdown', required: false)
if markdown_dep.found()
    executable('markdown', 'app.vala',
               dependencies: [glib_dep, gobject_dep, gio_dep, soup_dep, vsgi_dep, valum_dep, markdown_dep],
               vala_args: ['--pkg=libmarkdown', '--vapidir=' + meson.current_source_dir() + '/vapi'])
endif
