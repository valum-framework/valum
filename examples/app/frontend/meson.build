frontend_sources = fs.copyfile('index.js')
package_json = fs.copyfile('package.json')
package_lock_json = fs.copyfile('package-lock.json')
webpack_config_js = fs.copyfile('webpack.config.js')

node_modules = custom_target(
    command: [npm_exe, '--prefix', meson.current_build_dir(), 'install'],
    input: [package_json, package_lock_json],
    output: 'node_modules',
)

js_bundle = custom_target(
    command: [npm_exe, '--prefix', meson.current_build_dir(), 'run', 'dist'],
    input: [frontend_sources, node_modules, webpack_config_js],
    output: ['bundle.js', 'bundle.css'],
)

frontend_resources = gnome.compile_resources(
    'frontend',
    'app.gresource.xml',
    c_name: 'frontend',
    source_dir: ['static', meson.current_build_dir()],
    dependencies: [js_bundle],
)
