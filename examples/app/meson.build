ctpl = dependency('ctpl', required: false)
gee = dependency('gee-0.8', required: false)
app_sources = [
    'app.vala',
    'view.vala',
    gnome.compile_resources('app-resources', 'app.gresource.xml', source_dir: '.')]
if ctpl.found() and gee.found()
    executable('app', app_sources,
               dependencies: [glib, gobject, gio, soup, vsgi, valum, ctpl, gee],
               vala_args: ['--vapidir=' + meson.current_source_dir() + '/vapi'])
endif
