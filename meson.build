project('Valum', ['vala', 'c'],
        version: '0.2.6',
        license: 'LGPL',
        meson_version: '>=0.31')

add_global_arguments(['-Wno-pointer-sign',
                      '-Wno-deprecated-declarations',
                      '-Wno-unused',
                      '-Wno-incompatible-pointer-types',
                      '-Wno-discarded-qualifiers'],
                     language: 'c')

add_global_arguments(['--target-glib=2.32',
                      '--enable-experimental',
                      '--enable-deprecated',
                      '--fatal-warnings'],
                     language: 'vala')

glib = dependency('glib-2.0', version: '>=2.32')
gobject = dependency('gobject-2.0', version: '>=2.32')
gio = dependency('gio-2.0', version: '>=2.32')
gio_unix = dependency('gio-unix-2.0', version: '>=2.32')
soup = dependency('libsoup-2.4', version: '>=2.38')

# provide 'GLib.ApplicationCommandLine.get_stdin'
if dependency('gio-2.0', version: '>=2.34', required: false).found()
add_global_arguments('--define=GIO_2_34', language: 'vala')
endif

# support parsing of CLI arguments
if dependency('gio-2.0', version: '>=2.40', required: false).found()
add_global_arguments('--define=GIO_2_40', language: 'vala')
endif

# provide 'OutputStream.write_all_async'
if dependency('gio-2.0', version: '>=2.44', required: false).found()
#add_global_arguments('--define=GIO_2_44', language: 'vala')
endif

# new 'Soup.Server' API
if dependency('libsoup-2.4', version: '>=2.48', required: false).found()
#add_global_arguments('--define=SOUP_2_48', language: 'vala')
endif

subdir('data')
subdir('src')
subdir('tests')
if get_option('enable_docs')
    subdir('docs')
endif
if get_option('enable_examples')
    subdir('examples')
endif
