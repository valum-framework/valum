gnome = import('gnome')
legacy_test_sources = [
    'tests.vala',
    'decode-test.vala',
    'route-test.vala',
    'server-sent-events-test.vala',
    'subdomain-test.vala']
test('legacy', executable('legacy-test', legacy_test_sources,
                          dependencies: [glib, gobject, gio, soup, vsgi, valum_dep]),
     env: ['G_TEST_SRCDIR=' + meson.current_source_dir()])

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
                          dependencies: [glib, gobject, gio, soup, vsgi, valum_dep]),
         env: ['G_TEST_SRCDIR=' + meson.current_source_dir()])
endforeach
