project('Valum', 'vala', 'c',
        version: '0.3.0-rc',
        license: 'LGPL',
        meson_version: '>=0.35')

api_version = '0.3'

if not meson.is_subproject()
add_global_arguments(['-Wall',
                      '-Wno-pointer-sign',
                      '-Wno-deprecated-declarations',
                      '-Wno-unused',
                      '-Wno-incompatible-pointer-types',
                      '-Wno-discarded-qualifiers'],
                     language: 'c')

add_global_arguments(['--enable-experimental',
                      '--enable-deprecated'],
                     language: 'vala')
endif

glib = dependency('glib-2.0', version: '>=2.40')
gobject = dependency('gobject-2.0', version: '>=2.40')
gio = dependency('gio-2.0', version: '>=2.40')
gio_unix = dependency('gio-unix-2.0', version: '>=2.40')
gmodule = dependency('gmodule-2.0', version: '>=2.40')
soup = dependency('libsoup-2.4', version: '>=2.44')

vala_defines = []

# provide 'OutputStream.write_all_async'
if gio.version().version_compare('>=2.44')
    vala_defines += '--define=GIO_2_44'
endif

# new 'Soup.Server' API
if soup.version().version_compare('>=2.48')
    vala_defines += '--define=SOUP_2_48'
endif

subdir('data')
subdir('src')
subdir('tests')
subdir('docs')
if get_option('enable_examples')
    subdir('examples')
endif
