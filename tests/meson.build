gnome = import('gnome')
legacy_test_sources = [
    'tests.vala',
    'cgi-test.vala',
    'cookies-test.vala',
    'decode-test.vala',
    'route-test.vala',
    'server-sent-events-test.vala',
    'subdomain-test.vala']
test('legacy', executable('legacy-test', legacy_test_sources,
                          dependencies: [glib, gobject, gio, soup, vsgi, valum]),
     env: ['G_TEST_SRCDIR=' + meson.current_source_dir()])

# VSGI tests
test('auth', executable('auth-test', 'auth-test.vala',
                        dependencies: [glib, gobject, gio, soup, vsgi]))
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
