vsgi_sources = [
    'vsgi.vala',
    'vsgi-cookie-utils.vala',
    'vsgi-request.vala',
    'vsgi-response.vala',
    'vsgi-bounded-input-stream.vala',
    'vsgi-chunked-encoder.vala',
    'vsgi-cookie-utils.vala',
    'vsgi-request.vala',
    'vsgi-response.vala',
    'vsgi-server.vala']
vsgi_lib = shared_library('vsgi', vsgi_sources,
                          dependencies: [glib, gobject, gio, soup],
                          vala_args: '--pkg=posix',
                          install: true)

vsgi = declare_dependency(include_directories: include_directories('.'), link_with: vsgi_lib)

install_headers(meson.current_build_dir() + '/vsgi.h', subdir: 'vsgi')

pkgconfig = import('pkgconfig')
pkgconfig.generate(requires: 'glib-2.0 gobject-2.0 gio-2.0 libsoup-2.4',
                   libraries: vsgi_lib,
                   version: meson.project_version(),
                   name: 'VSGI',
                   filebase: 'vsgi',
                   description: 'Interface and implementations for various web server technologies')
