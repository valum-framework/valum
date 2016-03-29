gnome = import('gnome')
legacy_test_sources = [
    'tests.vala',
    'cgi-test.vala',
    'chunked-encoder-test.vala',
    'cookies-test.vala',
    'fastcgi-test.vala',
    'http-test.vala',
    'negociate-test.vala',
    'router-test.vala',
    'route-test.vala',
    'scgi-test.vala',
    'server-sent-events-test.vala',
    'subdomain-test.vala',
    gnome.compile_resources('tests-resources', 'tests.gresource.xml', source_dir: '.')]
test('legacy', executable('legacy-test', legacy_test_sources,
                          dependencies: [glib, gobject, gio, soup, vsgi, vsgi_cgi, vsgi_scgi, vsgi_fastcgi, vsgi_http, vsgi_mock, valum]))
test('basepath', executable('basepath-test', ['basepath-test.vala'],
                            dependencies: [glib, gobject, gio, soup, vsgi, vsgi_mock, valum]))
