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
vsgi_tests = [
    'application',
    'auth',
    'http-server',
    'multipart',
    'request',
    'response',
    'server',
    'socket-server']

foreach name : vsgi_tests
    test(name, executable(name + '-test', name + '-test.vala',
                          dependencies: [glib, gobject, gio, gio_unix, soup, vsgi]),
         env: ['G_TEST_SRCDIR=' + meson.current_source_dir()])
endforeach

if fcgi.found()
    test('fastcgi server', executable('fastcgi-server-test', 'fastcgi-server-test.vala',
                                      dependencies: [glib, gobject, gio, gio_unix, soup, vsgi]))
endif

loader_test_lib = shared_library('loader-test', 'loader-test.vala',
                                 dependencies: [glib, gobject, gio, gio_unix, soup, vsgi])
test('loader', vsgi_loader,
     args: ['--directory', meson.current_build_dir(), '--server=cgi', 'loader-test'],
     env: ['VSGI_SERVER_PATH=src/vsgi/servers'])

# Valum tests
valum_tests = [
    'authenticate',
    'basepath',
    'basic',
    'content-negotiation',
    'context',
    'router',
    'rule-route',
    'safely',
    'status']

foreach name : valum_tests
    test(name, executable(name + '-test', name + '-test.vala',
                          dependencies: [glib, gobject, gio, soup, vsgi, valum]),
         env: ['G_TEST_SRCDIR=' + meson.current_source_dir()])
endforeach
