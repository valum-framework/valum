libsystemd = dependency('libsystemd', required: false)

valadoc = find_program('valadoc', required: false)

if valadoc.found()
    valadoc_command = [valadoc, '--package-name', 'valum-@0@'.format(api_version),
                       '--package-version', meson.project_version(), '--pkg=glib-2.0',
                       '--pkg=gio-2.0', '--pkg=gio-unix-2.0',
                       '--pkg=gmodule-2.0', '--pkg=libsoup-2.4', '--pkg=posix', '--pkg=openssl',
                       '--vapidir=' + join_paths(meson.current_source_dir(), '..', 'vapi'),
                       '--target-glib=2.40', '--force', '--directory', '@OUTPUT@', '@INPUT@']

    # provide structured logging
    if glib.version().version_compare('>=2.50')
        valadoc_command += '--define=GLIB_2_50'
    endif

    # provide 'OutputStream.write_all_async' and 'SimpleIOStream'
    if gio.version().version_compare('>=2.44')
        valadoc_command += '--define=GIO_2_44'
    endif

    # new 'Soup.Server' API
    if soup.version().version_compare('>=2.48')
        valadoc_command += '--define=SOUP_2_48'
    endif

    # 'Soup.ClientContext.steal_connection'
    if soup.version().version_compare('>=2.50')
        valadoc_command += '--define=SOUP_2_50'
    endif

    if libsystemd.found()
        valadoc_command += '--define=LIBSYSTEMD'
    endif

    custom_target('API documentation', command: valadoc_command + ['--doclet=html'],
                 input: subproject('vsgi').get_variable('vsgi_sources') + valum_sources,
                 output: 'api',
                 build_by_default: true)
    install_subdir(meson.current_build_dir() + '/api', install_dir: 'share/doc/valum-@0@'.format(api_version))
    custom_target('Devhelp book', command: valadoc_command + ['--doclet=devhelp'],
                 input: subproject('vsgi').get_variable('vsgi_sources') + valum_sources,
                 output: 'devhelp',
                 build_by_default: true)
    install_subdir(meson.current_build_dir() + '/devhelp/valum-@0@'.format(api_version), install_dir: 'share/devhelp/books')
endif

sphinx = find_program('sphinx-build-3', required: false)
if not sphinx.found()
    sphinx = find_program('sphinx-build', required: false)
endif
if sphinx.found()
    docs_sources = [
        'about/gnu-lgpl-v3.0.rst',
        'application.rst',
        'getting-started.rst',
        'hacking.rst',
        'index.rst',
        'installation.rst',
        'middlewares/authenticate.rst',
        'middlewares/basepath.rst',
        'middlewares/basic.rst',
        'middlewares/content-negotiation.rst',
        'middlewares/decode.rst',
        'middlewares/index.rst',
        'middlewares/respond-with.rst',
        'middlewares/safely.rst',
        'middlewares/sequence.rst',
        'middlewares/server-sent-events.rst',
        'middlewares/static.rst',
        'middlewares/status.rst',
        'middlewares/subdomain.rst',
        'middlewares/websocket.rst',
        'recipes/bump.rst',
        'recipes/caching.rst',
        'recipes/configuration.rst',
        'recipes/index.rst',
        'recipes/json.rst',
        'recipes/persistence.rst',
        'recipes/scripting.rst',
        'recipes/static-resource.rst',
        'recipes/templating.rst',
        'redirection-and-error.rst',
        'router.rst',
        'vsgi/authentication.rst',
        'vsgi/connection.rst',
        'vsgi/converters.rst',
        'vsgi/cookies.rst',
        'vsgi/index.rst',
        'vsgi/request.rst',
        'vsgi/response.rst',
        'vsgi/server/cgi.rst',
        'vsgi/server/fastcgi.rst',
        'vsgi/server/http.rst',
        'vsgi/server/index.rst',
        'vsgi/server/scgi.rst']
    custom_target('en user documentation',
                  command: [sphinx, '-W', '-b', 'html', meson.current_source_dir(), '@OUTPUT@'],
                  input: docs_sources,
                  output: 'en',
                  build_by_default: true)
    install_subdir(meson.current_build_dir() + '/en', install_dir: 'share/doc/valum-@0@/user'.format(api_version))
endif
