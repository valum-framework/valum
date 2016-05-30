fcgi = meson.get_compiler('c').find_library('fcgi')
library('vsgi-fastcgi', 'vsgi-fastcgi.vala',
        dependencies: [glib, gobject, gio, gio_unix, soup, vsgi, fcgi],
        vala_args: ['--pkg=fcgi', '--vapidir=' + meson.current_source_dir(), '--target-glib=2.32'] + vala_defines,
        install: true)
