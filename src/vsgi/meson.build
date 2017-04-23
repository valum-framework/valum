vsgi_sources = files(
    'vsgi.vala',
    'vsgi-application.vala',
    'vsgi-authentication.vala',
    'vsgi-authorization.vala',
    'vsgi-basic-authentication.vala',
    'vsgi-basic-authorization.vala',
    'vsgi-bounded-input-stream.vala',
    'vsgi-cookie-utils.vala',
    'vsgi-handler-module.vala',
    'vsgi-handler.vala',
    'vsgi-multipart-input-stream.vala',
    'vsgi-multipart-output-stream.vala',
    'vsgi-request.vala',
    'vsgi-response.vala',
    'vsgi-server-module.vala',
    'vsgi-server.vala',
    'vsgi-socket-server.vala',
    'vsgi-tee-output-stream.vala')
vsgi_lib = library('vsgi-' + api_version, vsgi_sources,
                   dependencies: [glib, gobject, gio, gio_unix, gmodule, soup, libsystemd, openssl],
                   vala_args: ['--pkg=posix'] + vala_defines,
                   vala_header: 'vsgi.h',
                   install: true,
                   install_rpath: '$ORIGIN/vsgi-@0@/servers'.format(api_version))

vsgi = declare_dependency(include_directories: include_directories('.'),
                          link_with: vsgi_lib,
                          link_args: '-Wl,-rpath,@0@/servers'.format(meson.current_build_dir()))

meson.add_install_script('install.sh')

vsgi_private_requires = ['gio-unix-2.0', 'gmodule-2.0']

if libsystemd.found()
    vsgi_private_requires += 'libsystemd'
endif

vsgi_private_requires += 'openssl'

pkgconfig = import('pkgconfig')
pkgconfig.generate(requires: 'glib-2.0 gobject-2.0 gio-2.0 libsoup-2.4',
                   requires_private: vsgi_private_requires,
                   libraries: vsgi_lib,
                   version: meson.project_version(),
                   name: 'VSGI',
                   filebase: 'vsgi-' + api_version,
                   description: 'Interface and implementations for various web server technologies',
                   subdirs: 'vsgi-' + api_version)

subdir('servers')
