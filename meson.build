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
gio_unix = dependency('gio-unix-2.0', version: '>=2.40', required: false)
gio_windows = dependency('gio-windows-2.0', version: '>=2.40', required: false)
gmodule = dependency('gmodule-2.0', version: '>=2.40')
soup = dependency('libsoup-2.4', version: '>=2.44')

if gio_unix.found()
    gio_platform = gio_unix
elif gio_windows.found()
    gio_platform = gio_windows
else
    error('Either \'gio-unix-2.0\' or \'gio-windows-2.0\' must be available.')
endif

# provide 'OutputStream.write_all_async' and 'SimpleIOStream'
if gio.version().version_compare('>=2.44')
    add_project_arguments('--define=GIO_2_44', language: 'vala')
endif

# provide 'UnixInputStream', 'UnixOutputStream' and 'UnixSocketAddress'
if gio_unix.found()
    add_project_arguments('--define=GIO_UNIX', language: 'vala')
endif

# provide 'Win32InputStream' and 'Win32OutputStream'
if gio_windows.found()
    add_project_arguments('--define=GIO_WINDOWS', language: 'vala')
endif

# new 'Soup.Server' API
if soup.version().version_compare('>=2.48')
    add_project_arguments('--define=SOUP_2_48', language: 'vala')
endif

if meson.get_compiler('c').links('void main (void) { fork (); }')
    add_project_arguments('--define=HAVE_FORK', language: 'vala')
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
