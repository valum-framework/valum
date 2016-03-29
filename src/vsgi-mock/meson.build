vsgi_mock_lib = shared_library('vsgi-mock', 'vsgi-mock.vala',
                               dependencies: [glib, gobject, gio, soup, vsgi],
                               install: true)

vsgi_mock = declare_dependency(include_directories: include_directories('.'),
                               link_with: vsgi_mock_lib)

install_headers(meson.current_build_dir() + '/vsgi-mock.h', subdir: 'vsgi')

pkgconfig = import('pkgconfig')
pkgconfig.generate(libraries: vsgi_mock_lib,
                   version: meson.project_version(),
                   name: 'Mock implementation of VSGI',
                   filebase: 'vsgi-mock',
                   description: 'Web micro-framework entirely written in Vala',
                   subdirs: 'vsgi')
