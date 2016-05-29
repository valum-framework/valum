vsgi_scgi_lib = library('vsgi-scgi', 'vsgi-scgi.vala',
                        dependencies: [glib, gobject, gio, soup, vsgi, vsgi_cgi],
                        vala_args: ['--target-glib=2.32'] + vala_defines,
                        install: true)

vsgi_scgi = declare_dependency(include_directories: include_directories('.'),
                               link_with: vsgi_scgi_lib)

install_headers(meson.current_build_dir() + '/vsgi-scgi.h', subdir: 'vsgi')

pkgconfig = import('pkgconfig')
pkgconfig.generate(requires: 'vsgi-cgi',
                   libraries: vsgi_scgi_lib,
                   version: meson.project_version(),
                   name: 'SCGI implementation of VSGI',
                   filebase: 'vsgi-scgi',
                   description: 'Web micro-framework entirely written in Vala',
                   subdirs: 'vsgi')

install_data('vsgi-scgi.deps', install_dir: 'share/vala/vapi')
