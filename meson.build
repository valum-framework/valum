project('Valum', 'vala', 'c',
        version: '0.4.0-dev',
        license: 'LGPL',
        meson_version: '>=0.40.0')

api_version = '0.4'

add_project_arguments(['--enable-experimental',
                       '--enable-deprecated',
                       '--vapidir=' + meson.current_source_dir() + '/vapi'],
                      language: 'vala')

glib = dependency('glib-2.0', version: '>=2.40')
gobject = dependency('gobject-2.0', version: '>=2.40')
gio = dependency('gio-2.0', version: '>=2.40')
gio_unix = dependency('gio-unix-2.0', version: '>=2.40')
gmodule = dependency('gmodule-2.0', version: '>=2.40')
soup = dependency('libsoup-2.4', version: '>=2.44')
libsystemd = dependency('libsystemd', required: false)
openssl = dependency('openssl')
posix = meson.get_compiler('vala').find_library('posix')

# provide structured logging
if glib.version().version_compare('>=2.50')
    add_project_arguments('--define=GLIB_2_50', language: 'vala')
endif

# provide 'OutputStream.write_all_async' and 'SimpleIOStream'
if gio.version().version_compare('>=2.44')
    add_project_arguments('--define=GIO_2_44', language: 'vala')
endif

# new 'Soup.Server' API
if soup.version().version_compare('>=2.48')
    add_project_arguments('--define=SOUP_2_48', language: 'vala')
endif

if libsystemd.found()
    add_project_arguments('--define=LIBSYSTEMD', language: 'vala')
endif

if meson.get_compiler('c').has_function('memmem')
    add_project_arguments('--define=HAVE_MEMMEM', language: 'vala')
endif

subdir('src')
subdir('bin')
subdir('tests')
subdir('docs')
if get_option('enable_examples')
    subdir('examples')
endif
