markdown = meson.get_compiler('c').find_library('markdown')
executable('markdown', 'app.vala',
           dependencies: [glib, gobject, gio, soup, vsgi, vsgi_http, valum, markdown],
           vala_args: ['--pkg=libmarkdown', '--vapidir=' + meson.current_source_dir() + '/vapi'])
