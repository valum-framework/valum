valum_sources = files(
    'valum.vala',
    'valum-asterisk-route.vala',
    'valum-authenticate.vala',
    'valum-basepath.vala',
    'valum-basic.vala',
    'valum-cache-control.vala',
    'valum-context.vala',
    'valum-decode.vala',
    'valum-forward.vala',
    'valum-forward-with.vala',
    'valum-matcher-route.vala',
    'valum-method.vala',
    'valum-middleware.vala',
    'valum-content-negotiation.vala',
    'valum-multipart.vala',
    'valum-path-route.vala',
    'valum-regex-route.vala',
    'valum-respond-with.vala',
    'valum-route.vala',
    'valum-router.vala',
    'valum-rule-route.vala',
    'valum-safely.vala',
    'valum-sequence.vala',
    'valum-server-sent-events.vala',
    'valum-static.vala',
    'valum-status.vala',
    'valum-subdomain.vala')
valum_lib = library('valum-' + api_version, valum_sources,
                    dependencies: [glib, gobject, gio, soup, vsgi],
                    vala_header: 'valum.h',
                    install: true,
                    install_dir: [true, true, true])

install_data('valum-@0@.deps'.format(api_version),
             install_dir: 'share/vala/vapi')

valum_dep = declare_dependency(include_directories: include_directories('.'),
                               link_with: valum_lib)

pkgconfig = import('pkgconfig')
pkgconfig.generate(requires: 'vsgi-' + api_version,
                   libraries: valum_lib,
                   version: meson.project_version(),
                   name: 'Valum',
                   filebase: 'valum-' + api_version,
                   description: 'Web micro-framework entirely written in Vala',
                   subdirs: 'valum-' + api_version)
