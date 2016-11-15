valadoc = find_program('valadoc', required: false)
if valadoc.found()
    valadoc_command = [valadoc, '--package-name', 'valum-@0@'.format(api_version),
                       '--package-version', meson.project_version(), '--pkg=glib-2.0',
                       '--pkg=gio-2.0', '--pkg=gio-unix-2.0',
                       '--pkg=gmodule-2.0', '--pkg=libsoup-2.4', '--pkg=posix',
                       '--target-glib=2.40', '--force'] + vala_defines + [ '--directory', '@OUTPUT@', '@INPUT@']
    custom_target('API documentation', command: valadoc_command + ['--doclet=html'],
                 input: vsgi_sources + valum_sources,
                 output: 'api')
    install_subdir(meson.current_build_dir() + '/api', install_dir: 'share/doc/valum-@0@'.format(api_version))
    custom_target('Devhelp book', command: valadoc_command + ['--doclet=devhelp'],
                 input: vsgi_sources + valum_sources,
                 output: 'devhelp')
    install_subdir(meson.current_build_dir() + '/devhelp/valum-@0@'.format(api_version), install_dir: 'share/devhelp/books')
endif

sphinx = find_program('sphinx-build-3', required: false)
if not sphinx.found()
    sphinx = find_program('sphinx-build', required: false)
endif
if sphinx.found()
    custom_target('en user documentation',
                  command: [sphinx, '-W', '-b', 'html', '@INPUT@', '@OUTPUT@'],
                  input: '.',
                  output: 'en')
    install_subdir(meson.current_build_dir() + '/en', install_dir: 'share/doc/valum-@0@/user'.format(api_version))
endif
