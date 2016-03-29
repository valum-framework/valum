vsgi_http_lib = shared_library('vsgi-http', ['vsgi-http.vala'],
                               dependencies: [glib, gobject, gio, gio_unix, soup, vsgi])

vsgi_http = declare_dependency(include_directories: include_directories('.'),
                               link_with: vsgi_http_lib)

install_headers(meson.current_build_dir() + '/vsgi-http.h', subdir: 'vsgi')

pkgconfig = import('pkgconfig')
pkgconfig.generate(libraries: vsgi_http_lib,
                   version: meson.project_version(),
                   name: 'HTTP implementation of VSGI',
                   filebase: 'vsgi-http',
                   description: 'Web micro-framework entirely written in Vala',
                   subdirs: 'vsgi')
