valum_sources = [
    'valum.vala',
    'valum-asterisk-route.vala',
    'valum-basepath.vala',
    'valum-basic.vala',
    'valum-cache-control.vala',
    'valum-context.vala',
    'valum-decode.vala',
    'valum-forward.vala',
    'valum-matcher-route.vala',
    'valum-method.vala',
    'valum-content-negotiation.vala',
    'valum-regex-route.vala',
    'valum-route.vala',
    'valum-router.vala',
    'valum-rule-route.vala',
    'valum-safely.vala',
    'valum-sequence.vala',
    'valum-server-sent-events.vala',
    'valum-static.vala',
    'valum-status.vala',
    'valum-subdomain.vala']
valum_lib = library('valum', valum_sources,
                    dependencies: [glib, gobject, gio, soup, vsgi],
                    vala_args: ['--target-glib=2.32'] + vala_defines,
                    install: true)

valum = declare_dependency(include_directories: include_directories('.'),
                           link_with: valum_lib)

install_headers(meson.current_build_dir() + '/valum.h', subdir: 'valum')

pkgconfig = import('pkgconfig')
pkgconfig.generate(requires: 'vsgi',
                   libraries: valum_lib,
                   version: meson.project_version(),
                   name: 'Valum',
                   filebase: 'valum',
                   description: 'Web micro-framework entirely written in Vala',
                   subdirs: 'valum')

install_data('valum.deps', install_dir: 'share/vala/vapi')
