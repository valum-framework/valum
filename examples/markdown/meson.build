markdown = meson.get_compiler('c').find_library('markdown', required: false)
if markdown.found()
    executable('markdown', 'app.vala',
               dependencies: [glib, gobject, gio, soup, vsgi, valum_dep, markdown],
               vala_args: ['--pkg=libmarkdown', '--vapidir=' + meson.current_source_dir() + '/vapi'])
endif
