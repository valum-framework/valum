project('valum', 'vala', 'c',
        version: '0.4.0-dev',
        license: 'LGPL',
        meson_version: '>=0.46.0')

api_version = '0.4'

add_project_arguments(['--enable-experimental',
                       '--enable-deprecated',
                       '--vapidir=' + meson.current_source_dir() + '/vapi'],
                      language: 'vala')

glib = dependency('glib-2.0', version: '>=2.56')
gobject = dependency('gobject-2.0', version: '>=2.56')
gio = dependency('gio-2.0', version: '>=2.56')
soup = dependency('libsoup-2.4', version: '>=2.62')
vsgi = dependency('vsgi', fallback: ['vsgi', 'vsgi_dep'])

vala_defines = []

add_project_arguments(vala_defines, language: 'vala')

subdir('src')
subdir('tests')
subdir('docs')
if get_option('enable_examples')
    subdir('examples')
endif
