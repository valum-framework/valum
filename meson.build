project('Valum', 'vala', 'c',
        version: '0.3.0-dev',
        license: 'LGPL',
        meson_version: '>=0.33')

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
                      '--enable-deprecated',
                      '--fatal-warnings'],
                     language: 'vala')
endif

glib = dependency('glib-2.0', version: '>=2.32')
gobject = dependency('gobject-2.0', version: '>=2.32')
gio = dependency('gio-2.0', version: '>=2.32')
gio_unix = dependency('gio-unix-2.0', version: '>=2.32')
gmodule = dependency('gmodule-2.0')
soup = dependency('libsoup-2.4', version: '>=2.38')

vala_defines = []

# support parsing of CLI arguments
if gio.version().version_compare('>=2.40')
    vala_defines += '--define=GIO_2_40'
endif

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
if get_option('enable_docs')
    subdir('docs')
endif
if get_option('enable_api_docs')
    valadoc = find_program('valadoc')
    custom_target('api-docs', command: [valadoc, '--package-name',
                  'valum', '--package-version', meson.project_version(),
                  '--pkg=glib-2.0', '--pkg=gio-2.0', '--pkg=gio-unix-2.0',
                  '--pkg=gmodule-2.0', '--pkg=libsoup-2.4', '--pkg=posix',
                  '--target-glib=2.32', '--force'] +
                  vala_defines +
                  [ '--directory', '@OUTPUT@', '@INPUT@'],
                  input: vsgi_sources + valum_sources,
                  output: 'api-docs')
endif
if get_option('enable_examples')
    subdir('examples')
endif
