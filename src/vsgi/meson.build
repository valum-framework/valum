vsgi_sources = files(
    'vsgi.vala',
    'vsgi-authentication.vala',
    'vsgi-authorization.vala',
    'vsgi-basic-authentication.vala',
    'vsgi-basic-authorization.vala',
    'vsgi-bounded-input-stream.vala',
    'vsgi-cgi.vala',
    'vsgi-chunked-encoder.vala',
    'vsgi-connection.vala',
    'vsgi-cookie-utils.vala',
    'vsgi-mock.vala',
    'vsgi-request.vala',
    'vsgi-response.vala',
    'vsgi-security-utils.vala',
    'vsgi-server-module.vala',
    'vsgi-server.vala',
    'vsgi-socket-listener-server.vala',
    'vsgi-tee-output-stream.vala',
    'vsgi-worker.vala')
vsgi_lib = library('vsgi-' + api_version, vsgi_sources,
                   dependencies: [glib, gobject, gio, gio_unix, gmodule, soup],
                   vala_args: ['--pkg=posix'] + vala_defines,
                   link_args: '-Wl,-rpath,$$ORIGIN/servers',
                   install: true,
                   install_rpath: '$ORIGIN/vsgi-@0@/servers'.format(api_version))

vsgi = declare_dependency(include_directories: include_directories('.'),
                          link_with: vsgi_lib)

install_headers(meson.current_build_dir() + '/vsgi-@0@.h'.format(api_version), subdir: 'vsgi-' + api_version)
install_data(meson.current_build_dir() + '/vsgi-@0@.vapi'.format(api_version), install_dir: 'share/vala/vapi')

pkgconfig = import('pkgconfig')
pkgconfig.generate(requires: 'glib-2.0 gobject-2.0 gio-2.0 libsoup-2.4',
                   requires_private: 'gmodule-2.0',
                   libraries: vsgi_lib,
                   version: meson.project_version(),
                   name: 'VSGI',
                   filebase: 'vsgi-' + api_version,
                   description: 'Interface and implementations for various web server technologies',
                   subdirs: 'vsgi-' + api_version)

install_data('vsgi-@0@.deps'.format(api_version), install_dir: 'share/vala/vapi')

subdir('servers')
