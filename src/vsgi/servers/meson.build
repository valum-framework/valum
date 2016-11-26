shared_library('vsgi-http', ['vsgi-http.vala'],
        dependencies: [glib, gobject, gio, soup, vsgi],
        vala_args: vala_defines,
        install: true,
        install_dir: '@0@/vsgi-@1@/servers'.format(get_option('libdir'), api_version))

shared_library('vsgi-cgi', 'vsgi-cgi.vala',
        dependencies: [glib, gobject, gio, gio_unix, soup, vsgi],
        vala_args: vala_defines,
        install: true,
        install_dir: '@0@/vsgi-@1@/servers'.format(get_option('libdir'), api_version))

fcgi = meson.get_compiler('c').find_library('fcgi', required: false)
if fcgi.found()
    fcgi_vapi = meson.get_compiler('vala').find_library('fcgi', dirs: meson.current_source_dir())
    shared_library('vsgi-fastcgi', 'vsgi-fastcgi.vala',
                   dependencies: [glib, gobject, gio, gio_unix, soup, vsgi, fcgi, fcgi_vapi],
                   vala_args: vala_defines,
                   install: true,
                   install_dir: '@0@/vsgi-@1@/servers'.format(get_option('libdir'), api_version))
endif

shared_library('vsgi-scgi', 'vsgi-scgi.vala',
        dependencies: [glib, gobject, gio, soup, vsgi],
        vala_args: vala_defines,
        install: true,
        install_dir: '@0@/vsgi-@1@/servers'.format(get_option('libdir'), api_version))
