shared_module('vsgi-http', ['vsgi-http.vala'],
        dependencies: [glib, gobject, gio, soup, vsgi],
        install: true,
        install_dir: join_paths(get_option('libdir'), 'vsgi-@0@/servers'.format(api_version)))

shared_module('vsgi-cgi', 'vsgi-cgi.vala',
        dependencies: [glib, gobject, gio, gio_unix, soup, vsgi],
        install: true,
        install_dir: join_paths(get_option('libdir'), 'vsgi-@0@/servers'.format(api_version)))

fcgi = meson.get_compiler('c').find_library('fcgi', required: false)
if fcgi.found()
    fcgi_vapi = meson.get_compiler('vala').find_library('fcgi', dirs: meson.current_source_dir())
    vsgi_fastcgi_internal = meson.get_compiler('vala').find_library('vsgi-fastcgi-internal', dirs: meson.current_source_dir())
    shared_module('vsgi-fastcgi', ['vsgi-fastcgi.vala', 'vsgi-fastcgi-input-stream.c', 'vsgi-fastcgi-output-stream.c'],
                   dependencies: [glib, gobject, gio, gio_unix, soup, vsgi, fcgi, fcgi_vapi, vsgi_fastcgi_internal],
                   install: true,
                   install_dir: join_paths(get_option('libdir'), 'vsgi-@0@/servers'.format(api_version)))
endif

shared_module('vsgi-scgi', 'vsgi-scgi.vala',
        dependencies: [glib, gobject, gio, soup, vsgi],
        install: true,
        install_dir: join_paths(get_option('libdir'), 'vsgi-@0@/servers'.format(api_version)))
