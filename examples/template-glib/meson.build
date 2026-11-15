template_glib_dep = dependency('template-glib-1.0', required: false)
if template_glib_dep.found()
    executable(
        'template-glib',
        [
            'app.vala',
            gnome.compile_resources(
                'template-glib-resources',
                'app.gresource.xml',
                source_dir: '.',
            ),
        ],
        dependencies: [
            glib_dep,
            gobject_dep,
            gio_dep,
            soup_dep,
            vsgi_dep,
            valum_dep,
            template_glib_dep,
        ],
    )
else
    warning('This example will not be built: template-glib-1.0 is missing.')
endif
