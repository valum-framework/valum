fs = import('fs')
ctpl_dep = dependency('ctpl', required: false)
gee_dep = dependency('gee-0.8', required: false)
npm_exe = find_program('npm', required: false)
if ctpl_dep.found() and gee_dep.found() and npm_exe.found()
    app_sources = ['app.vala', 'view.vala']
    subdir('frontend')
    subdir('templates')
    executable(
        'app',
        app_sources + templates_resources + frontend_resources,
        dependencies: [
            glib_dep,
            gobject_dep,
            gio_dep,
            soup_dep,
            vsgi_dep,
            valum_dep,
            ctpl_dep,
            gee_dep,
        ],
        vala_args: ['--vapidir=' + meson.current_source_dir() + '/vapi'],
    )
else
    warning('The example will not be built: one of ctpl or gee-0.8 is missing.')
endif
