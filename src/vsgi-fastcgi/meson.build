fcgi = find_library('fcgi')
vsgi_fastcgi_lib = shared_library('vsgi-fastcgi', 'vsgi-fastcgi.vala',
                                  dependencies: [glib, gobject, gio, gio_unix, soup, vsgi, vsgi_cgi, fcgi],
                                  vala_args: ['--pkg=fcgi', '--vapidir=' + meson.current_source_dir()],
                                  install: true)

vsgi_fastcgi = declare_dependency(include_directories: include_directories('.'),
                                  link_with: vsgi_fastcgi_lib)

install_headers(meson.current_build_dir() + '/vsgi-fastcgi.h', subdir: 'vsgi')

pkgconfig = import('pkgconfig')
pkgconfig.generate(libraries: vsgi_fastcgi_lib,
                   version: meson.project_version(),
                   name: 'FastCGI implementation of VSGI',
                   filebase: 'vsgi-fastcgi',
                   description: 'Web micro-framework entirely written in Vala',
                   subdirs: 'vsgi')
