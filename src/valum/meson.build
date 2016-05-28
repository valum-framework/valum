valum_sources = [
    'valum.vala',
    'valum-asterisk-route.vala',
    'valum-basepath.vala',
    'valum-context.vala',
    'valum-matcher-route.vala',
    'valum-method.vala',
    'valum-negociate.vala',
    'valum-regex-route.vala',
    'valum-route.vala',
    'valum-router.vala',
    'valum-rule-route.vala',
    'valum-server-sent-events.vala',
    'valum-status.vala',
    'valum-subdomain.vala']
valum_lib = library('valum', valum_sources,
                    dependencies: [glib, gobject, gio, soup, vsgi],
                    install: true)

valum = declare_dependency(include_directories: include_directories('.'),
                           link_with: valum_lib)

pkgconfig = import('pkgconfig')
pkgconfig.generate(requires: 'vsgi',
                   libraries: valum_lib,
                   version: meson.project_version(),
                   name: 'Valum',
                   filebase: 'valum',
                   description: 'Web micro-framework entirely written in Vala',
                   subdirs: 'valum')

install_data('valum.deps', install_dir: 'share/vala/vapi')
