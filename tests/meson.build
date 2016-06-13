gnome = import('gnome')
legacy_test_sources = [
    'tests.vala',
    'cgi-test.vala',
    'chunked-encoder-test.vala',
    'cookies-test.vala',
    'decode-test.vala',
    'router-test.vala',
    'route-test.vala',
    'server-sent-events-test.vala',
    'subdomain-test.vala',
    gnome.compile_resources('tests-resources', 'tests.gresource.xml', source_dir: '.')]
test('legacy', executable('legacy-test', legacy_test_sources,
                          dependencies: [glib, gobject, gio, soup, vsgi, valum]))

# VSGI tests
test('request', executable('request-test', 'request-test.vala',
                           dependencies: [glib, gobject, gio, soup, vsgi]))
test('server', executable('server-test', 'server-test.vala',
                           dependencies: [glib, gobject, gio, soup, vsgi]))
test('socket listener server', executable('socket-listener-server-test', 'socket-listener-server-test.vala',
                                          dependencies: [glib, gobject, gio, gio_unix,  soup, vsgi]))
if fcgi.found()
	test('fastcgi server', executable('fastcgi-server-test', 'fastcgi-server-test.vala',
					  dependencies: [glib, gobject, gio, soup, vsgi]))
endif

# Valum tests
test('basepath', executable('basepath-test', ['basepath-test.vala'],
                            dependencies: [glib, gobject, gio, soup, vsgi, valum]))
test('content negotiation', executable('content-negotiation-test', ['content-negotiation-test.vala'],
                                       dependencies: [glib, gobject, gio, soup, vsgi, valum]))
test('status', executable('status-test', ['status-test.vala'],
                                       dependencies: [glib, gobject, gio, soup, vsgi, valum]))
