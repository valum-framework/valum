vsgi_cgi_lib = shared_library('vsgi-cgi', 'vsgi-cgi.vala',
                              dependencies: [glib, gobject, gio, gio_unix, soup, vsgi],
                              install: true)

vsgi_cgi = declare_dependency(include_directories: include_directories('.'), link_with: vsgi_cgi_lib)

install_headers(meson.current_build_dir() + '/vsgi-cgi.h', subdir: 'vsgi')

pkgconfig = import('pkgconfig')
pkgconfig.generate(libraries: vsgi_cgi_lib,
                   version: meson.project_version(),
                   name: 'CGI implementation of VSGI',
                   filebase: 'vsgi-cgi',
                   description: 'Web micro-framework entirely written in Vala',
                   subdirs: 'vsgi')
