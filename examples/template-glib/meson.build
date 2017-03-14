template_glib_dep = dependency('template-glib_dep-1.0', required: false)
if template_glib_dep.found()
    executable('template-glib_dep', ['app.vala', gnome.compile_resources('template-glib_dep-resources', 'app.gresource.xml', source_dir: '.')],
               dependencies: [glib_dep, gobject_dep, gio_dep, soup_dep, vsgi_dep, valum_dep, template_glib_dep])
endif
