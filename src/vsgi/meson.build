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
    'vsgi-security-utils.vala',
    'vsgi-server-module.vala',
    'vsgi-server.vala',
    'vsgi-socket-server.vala',
    'vsgi-tee-output-stream.vala')
vsgi_lib = library('vsgi-' + api_version, vsgi_sources,
                   dependencies: [glib, gobject, gio, gio_unix, gmodule, soup],
                   vala_args: ['--pkg=posix'] + vala_defines,
                   vala_header: 'vsgi.h',
                   vala_gir: 'VSGI-@0@.gir'.format(api_version),
                   c_args: '-DGETTEXT_PACKAGE="vsgi-@0@"'.format(api_version),
                   install: true,
                   install_rpath: '$ORIGIN/vsgi-@0@/servers'.format(api_version))

vsgi = declare_dependency(include_directories: include_directories('.'),
                          link_with: vsgi_lib,
                          link_args: '-Wl,-rpath,@0@/servers'.format(meson.current_build_dir()))

meson.add_install_script('install.sh')

g_ir_compiler = find_program('g-ir-compiler', required: false)
if g_ir_compiler.found()
    custom_target('VSGI typelib',
                  command: [g_ir_compiler, '--shared-library', vsgi_lib.full_path(),
                                           '--output', '@OUTPUT@',
                                            meson.current_build_dir() + '/VSGI-@0@.gir'.format(api_version)],
                  output: 'VSGI-@0@.typelib'.format(api_version),
                  install: true,
                  install_dir: '@0@/girepository-1.0'.format(get_option('libdir')))
endif

pkgconfig = import('pkgconfig')
pkgconfig.generate(requires: 'glib-2.0 gobject-2.0 gio-2.0 libsoup-2.4',
                   requires_private: 'gio-unix-2.0 gmodule-2.0',
                   libraries: vsgi_lib,
                   version: meson.project_version(),
                   name: 'VSGI',
                   filebase: 'vsgi-' + api_version,
                   description: 'Interface and implementations for various web server technologies',
                   subdirs: 'vsgi-' + api_version)

subdir('servers')
