ctpl = dependency('ctpl', required: false)
gee = dependency('gee-0.8', required: false)
if ctpl.found() and gee.found()
    app_sources = [
        'app.vala',
        'view.vala',
        gnome.compile_resources('app-resources', 'app.gresource.xml', source_dir: '.')]
    executable('app', app_sources,
               dependencies: [glib, gobject, gio, soup, vsgi, valum_dep, ctpl, gee],
               vala_args: ['--vapidir=' + meson.current_source_dir() + '/vapi'])
else
    warning('The example will not be built: one of ctpl or gee-0.8 is missing.')
endif
