project('Valum', ['vala', 'c'],
        version: '0.3.0-dev',
        license: 'LGPL',
        meson_version: '>=0.31')

if not meson.is_subproject()
add_global_arguments(['-Wall',
                      '-Wno-pointer-sign',
                      '-Wno-deprecated-declarations',
                      '-Wno-unused',
                      '-Wno-incompatible-pointer-types',
                      '-Wno-discarded-qualifiers'],
                     language: 'c')

add_global_arguments(['--enable-experimental',
                      '--enable-deprecated',
                      '--fatal-warnings'],
                     language: 'vala')
endif

vala_defines = []

# provide 'OutputStream.write_all_async'
if dependency('gio-2.0', version: '>=2.44', required: false).found()
  vala_defines += ['--define=GIO_2_44', '--define=GIO_2_40', '--define=GIO_2_34']

# support parsing of CLI arguments
elif dependency('gio-2.0', version: '>=2.40', required: false).found()
  vala_defines += ['--define=GIO_2_40', '--define=GIO_2_34']

# provide 'GLib.ApplicationCommandLine.get_stdin'
elif dependency('gio-2.0', version: '>=2.34', required: false).found()
  vala_defines += ['--define=GIO_2_34']
endif

# new 'Soup.Server' API
if dependency('libsoup-2.4', version: '>=2.48', required: false).found()
    vala_defines += '--define=SOUP_2_48'
endif

glib = dependency('glib-2.0', version: '>=2.32')
gobject = dependency('gobject-2.0', version: '>=2.32')
gio = dependency('gio-2.0', version: '>=2.32')
gio_unix = dependency('gio-unix-2.0', version: '>=2.32')
soup = dependency('libsoup-2.4', version: '>=2.38')

meson.add_install_script('install.sh')

subdir('data')
subdir('src')
subdir('tests')
if get_option('enable_docs')
    subdir('docs')
endif
if get_option('enable_examples')
    subdir('examples')
endif
