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
                          dependencies: [glib_dep, gobject_dep, gio_dep, soup_dep, vsgi_dep, valum_dep]))

vsgi_tests = [
    'auth',
    'multipart',
    'request',
    'http-server',
    'response',
    'server']
if fcgi_dep.found()
    vsgi_tests += 'fastcgi-server'
endif
foreach name : vsgi_tests
test(name, executable(name + '-test', name + '-test.vala',
                      dependencies: [glib_dep, gobject_dep, gio_dep, gio_unix_dep, soup_dep, vsgi_dep]),
     env: ['G_TEST_SRCDIR=' + meson.current_source_dir()])
endforeach

loader_test_lib = shared_library('loader-test', 'loader-test.vala',
                                 dependencies: [glib_dep, gobject_dep, gio_dep, gio_unix_dep, soup_dep, vsgi_dep])
test('loader', vsgi_loader,
     args: ['--directory', meson.current_build_dir(), '--server=cgi', 'loader-test'],
     env: ['VSGI_SERVER_PATH=' + meson.current_build_dir() + '/../src/vsgi/servers'])

python = find_program('python3')
test('gi', python,
     args: meson.current_source_dir() + '/gi-test.py' ,
     env: ['GI_TYPELIB_PATH=' + meson.current_build_dir() + '/../src/vsgi'])

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
    test(name, executable(name, [name + '-test.vala'],
                                dependencies: [glib_dep, gobject_dep, gio_dep, soup_dep, vsgi_dep, valum_dep]),
         env: ['G_TEST_SRCDIR=' + meson.current_source_dir()])
endforeach
