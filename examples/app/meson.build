ctpl = dependency('ctpl', required: false)
gee = dependency('gee-0.8', required: false)
bower = find_program('bower', required: false)
if bower.found() and ctpl.found() and gee.found()
    custom_target('static assets', command: [bower, 'install', '--config.cwd=' + meson.current_source_dir()],
                  input: 'bower.json',
                  output: 'static',
                  build_by_default: true)
    app_sources = [
        'app.vala',
        'view.vala',
        gnome.compile_resources('app-resources', 'app.gresource.xml', source_dir: '.')]
    executable('app', app_sources,
               dependencies: [glib, gobject, gio, soup, vsgi, valum, ctpl, gee],
               vala_args: ['--vapidir=' + meson.current_source_dir() + '/vapi'])
endif
