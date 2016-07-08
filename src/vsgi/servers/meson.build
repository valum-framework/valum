shared_library('vsgi-http', ['vsgi-http.vala'],
        dependencies: [glib, gobject, gio, soup, vsgi],
        vala_args: vala_defines,
        install: true,
        install_dir: '@0@/vsgi/servers'.format(get_option('libdir')))

shared_library('vsgi-cgi', 'vsgi-cgi.vala',
        dependencies: [glib, gobject, gio, gio_unix, soup, vsgi],
        vala_args: vala_defines,
        install: true,
        install_dir: '@0@/vsgi/servers'.format(get_option('libdir')))

fcgi = meson.get_compiler('c').find_library('fcgi', required: false)
if fcgi.found()
    shared_library('vsgi-fastcgi', 'vsgi-fastcgi.vala',
                   dependencies: [glib, gobject, gio, gio_unix, soup, vsgi, fcgi],
                   vala_args: ['--pkg=fcgi', '--vapidir=' + meson.current_source_dir()] + vala_defines,
                   install: true,
                   install_dir: '@0@/vsgi/servers'.format(get_option('libdir')))
endif

shared_library('vsgi-scgi', 'vsgi-scgi.vala',
        dependencies: [glib, gobject, gio, soup, vsgi],
        vala_args: vala_defines,
        install: true,
        install_dir: '@0@/vsgi/servers'.format(get_option('libdir')))

shared_library('vsgi-mock', 'vsgi-mock.vala',
        dependencies: [glib, gobject, gio, soup, vsgi],
        vala_args: vala_defines,
        install: true,
        install_dir: '@0@/vsgi/servers'.format(get_option('libdir')))
