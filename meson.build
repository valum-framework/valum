project('valum', 'vala', 'c',
        version: '0.4.0-dev',
        license: 'LGPL',
        meson_version: '>=1.3')

api_version = '0.4'

add_project_arguments(['--enable-experimental',
                       '--target-glib=2.80',
                       '--vapidir=' + meson.current_source_dir() / 'vapi'],
                      language: 'vala')

glib_dep = dependency('glib-2.0', version: '>=2.80')
gobject_dep = dependency('gobject-2.0', version: '>=2.80')
gio_dep = dependency('gio-2.0', version: '>=2.80')
soup_dep = dependency('libsoup-2.4', version: '>=2.74')
vsgi_dep = dependency('vsgi')

vala_defines = []

add_project_arguments(vala_defines, language: 'vala')

subdir('src')
subdir('tests')
subdir('docs')
if get_option('enable_examples')
    subdir('examples')
endif
