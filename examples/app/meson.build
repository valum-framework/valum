ctpl = dependency('ctpl')
gee = dependency('gee-0.8')
app_sources = [
    'app.vala',
    'view.vala',
    gnome.compile_resources('app-resources', 'app.gresource.xml', source_dir: '.')]
executable('app', app_sources,
           dependencies: [glib, gobject, gio, soup, vsgi, vsgi_http, valum, ctpl, gee],
           vala_args: ['--vapidir=' + meson.current_source_dir() + '/vapi'])
