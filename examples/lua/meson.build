lua_dep = dependency('lua-5.1')
executable(
    'lua',
    'app.vala',
    dependencies: [
        glib_dep,
        gobject_dep,
        gio_dep,
        soup_dep,
        vsgi_dep,
        valum_dep,
        lua_dep,
    ],
    vala_args: ['--vapidir=' + meson.current_source_dir() + '/vapi'],
)
