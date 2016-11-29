gnome = import('gnome')
legacy_test_sources = [
    'tests.vala',
    'cgi-test.vala',
    'cookies-test.vala',
    'decode-test.vala',
    'route-test.vala',
    'server-sent-events-test.vala',
    'subdomain-test.vala',
    gnome.compile_resources('tests-resources', 'tests.gresource.xml', source_dir: '.')]
test('legacy', executable('legacy-test', legacy_test_sources,
                          dependencies: [glib, gobject, gio, soup, vsgi, valum]))

# VSGI tests
test('auth', executable('auth-test', 'auth-test.vala',
                        dependencies: [glib, gobject, gio, soup, vsgi]))
test('multipart', executable('multipart-test', 'multipart-test.vala',
                             dependencies: [glib, gobject, gio, soup, vsgi]),
     env: ['G_TEST_SRCDIR=' + meson.current_source_dir()])
test('request', executable('request-test', 'request-test.vala',
                           dependencies: [glib, gobject, gio, soup, vsgi]))
test('response', executable('response-test', 'response-test.vala',
                           dependencies: [glib, gobject, gio, soup, vsgi]))
test('server', executable('server-test', 'server-test.vala',
                           dependencies: [glib, gobject, gio, soup, vsgi]))
test('http server', executable('http-server-test', 'http-server-test.vala',
                               dependencies: [glib, gobject, gio, gio_unix,  soup, vsgi]),
     env: ['G_TEST_SRCDIR=' + meson.current_source_dir()])
test('socket server', executable('socket-server-test', 'socket-server-test.vala',
                                          dependencies: [glib, gobject, gio, gio_unix,  soup, vsgi]))
if fcgi.found()
    test('fastcgi server', executable('fastcgi-server-test', 'fastcgi-server-test.vala',
                                      dependencies: [glib, gobject, gio, gio_unix, soup, vsgi]))
endif
loader_test_lib = shared_library('loader-test', 'loader-test.vala',
                                 dependencies: [glib, gobject, gio, gio_unix, soup, vsgi])
test('loader', vsgi_loader,
     args: ['--directory', meson.current_build_dir(), '--server=cgi', 'loader-test'],
     env: ['VSGI_SERVER_PATH=src/vsgi/servers'])

python = find_program('python3')
test('gi', python,
     args: meson.current_source_dir() + '/gi-test.py' ,
     env: ['GI_TYPELIB_PATH=' + meson.current_build_dir() + '/../src/vsgi'])

# Valum tests
test('authenticate', executable('authenticate-test', ['authenticate-test.vala'],
                            dependencies: [glib, gobject, gio, soup, vsgi, valum]))
test('basepath', executable('basepath-test', ['basepath-test.vala'],
                            dependencies: [glib, gobject, gio, soup, vsgi, valum]))
test('basic', executable('basic-test', 'basic-test.vala',
                            dependencies: [glib, gobject, gio, soup, vsgi, valum]))
test('content negotiation', executable('content-negotiation-test', ['content-negotiation-test.vala'],
                                       dependencies: [glib, gobject, gio, soup, vsgi, valum]))
test('context', executable('context-test', ['context-test.vala'],
                                       dependencies: [glib, gobject, gio, soup, vsgi, valum]))
test('safely', executable('safely-test', 'safely-test.vala',
                          dependencies: [glib, gobject, gio, soup, vsgi, valum]))
test('router', executable('router-test', 'router-test.vala',
                          dependencies: [glib, gobject, gio, soup, vsgi, valum]))
test('rule route', executable('rule-route-test', 'rule-route-test.vala',
                              dependencies: [glib, gobject, gio, soup, vsgi, valum]))
test('status', executable('status-test', ['status-test.vala'],
                                       dependencies: [glib, gobject, gio, soup, vsgi, valum]))
