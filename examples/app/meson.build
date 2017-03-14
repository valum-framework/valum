ctpl_dep = dependency('ctpl', required: false)
gee_dep = dependency('gee-0.8', required: false)
app_sources = [
    'app.vala',
    'view.vala',
    gnome.compile_resources('app-resources', 'app.gresource.xml', source_dir: '.')]
if ctpl_dep.found() and gee_dep.found()
    executable('app', app_sources,
               dependencies: [glib_dep, gobject_dep, gio_dep, soup_dep, vsgi_dep, valum_dep, ctpl_dep, gee_dep],
               vala_args: ['--vapidir=' + meson.current_source_dir() + '/vapi'])
endif
