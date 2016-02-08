#!/usr/bin/env python

import glob

APPNAME='valum'
VERSION='0.2.6'
API_VERSION='0.2'

def options(opt):
    opt.load('compiler_c')
    opt.add_option('--enable-gcov', action='store_true', default=False, help='enable coverage with gcov')
    opt.add_option('--enable-examples', action='store_true', default=False, help='build examples')
    opt.recurse('tests')

def configure(conf):
    conf.load('compiler_c vala')

    conf.check_vala(min_version=(0,26,0))
    conf.check(lib='gcov', mandatory=False, uselib_store='GCOV', args='--cflags --libs')
    conf.find_program('valadoc', mandatory=False)

    conf.recurse(['src', 'docs', 'tests'])

    conf.env.append_unique('CFLAGS', ['-Wall',
                                      '-Wno-deprecated-declarations',
                                      '-Wno-unused-variable',
                                      '-Wno-unused-but-set-variable',
                                      '-Wno-unused-function'])
    conf.env.append_unique('VALAFLAGS', ['--enable-experimental', '--enable-deprecated', '--fatal-warnings'])

    if conf.options.enable_gcov:
        conf.env.append_unique('CFLAGS', ['-fprofile-arcs', '-ftest-coverage'])
        conf.env.append_unique('VALAFLAGS', ['--debug'])

    # configure examples
    if conf.options.enable_examples:
        conf.env.ENABLE_EXAMPLES = True
        conf.recurse(glob.glob('examples/*'))

def build(bld):
    bld.load('compiler_c vala')
    bld.recurse(['src', 'data', 'docs', 'tests'])

    # generate the api documentation
    if bld.env.VALADOC:
        bld.load('valadoc')
        bld(
            features        = 'valadoc',
            packages        = ['glib-2.0', 'gio-2.0', 'gio-unix-2.0', 'libsoup-2.4', 'fcgi'],
            files           = bld.path.ant_glob('src/**/*.vala'),
            vala_defines    = 'GLIB_2_32',
            package_name    = 'valum',
            package_version = VERSION,
            vapi_dirs       = 'src/vsgi-fastcgi',
            output_dir      = 'apidocs',
            force           = True)

    # build examples
    if bld.env.ENABLE_EXAMPLES:
        bld.recurse(glob.glob('examples/*'))
