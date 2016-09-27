project('Valum', 'vala', 'c',
        version: '0.4.0-dev',
        license: 'LGPL',
        meson_version: '>=0.38.0')

api_version = '0.4'

add_project_arguments(['--enable-experimental',
                       '--enable-deprecated'],
                      language: 'vala')

glib = dependency('glib-2.0', version: '>=2.40')
gobject = dependency('gobject-2.0', version: '>=2.40')
gio = dependency('gio-2.0', version: '>=2.40')
gio_unix = dependency('gio-unix-2.0', version: '>=2.40')
gmodule = dependency('gmodule-2.0', version: '>=2.40')
soup = dependency('libsoup-2.4', version: '>=2.44')

vala_defines = []

# provide structured logging
if glib.version().version_compare('>=2.50')
    vala_defines += '--define=GLIB_2_50'
endif

# provide 'OutputStream.write_all_async' and 'SimpleIOStream'
if gio.version().version_compare('>=2.44')
    vala_defines += '--define=GIO_2_44'
endif

# new 'Soup.Server' API
if soup.version().version_compare('>=2.48')
    vala_defines += '--define=SOUP_2_48'
endif

if meson.get_compiler('c').has_function('memmem')
    vala_defines += '--define=HAVE_MEMMEM'
endif

subdir('src')
subdir('bin')
subdir('tests')
subdir('docs')
if get_option('enable_examples')
    subdir('examples')
endif
