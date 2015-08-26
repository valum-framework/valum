#!/usr/bin/env python

import glob

APPNAME='valum'
VERSION='0.2.0'
API_VERSION='0.2'

def options(opt):
    opt.load('compiler_c')
    opt.add_option('--enable-gcov', action='store_true', default=False, help='enable coverage with gcov')
    opt.add_option('--enable-examples', action='store_true', default=False, help='build examples')

def configure(conf):
    conf.load('compiler_c vala')

    conf.check_cfg(package='glib-2.0', atleast_version='2.32', uselib_store='GLIB', args='--cflags --libs')
    conf.check_cfg(package='gio-2.0', atleast_version='2.32', uselib_store='GIO', args='--cflags --libs')
    conf.check_cfg(package='ctpl', atleast_version='0.3.3', uselib_store='CTPL', args='--cflags --libs')
    conf.check_cfg(package='gee-0.8', atleast_version='0.6.4', uselib_store='GEE', args='--cflags --libs')
    conf.check_cfg(package='libsoup-2.4', atleast_version='2.38',uselib_store='SOUP', args='--cflags --libs')

    # glib (>=2.38) to enable subprocess in tests
    if conf.check_cfg(package='glib-2.0', atleast_version='2.38', mandatory=False, uselib_store='GLIB', args='--cflags --libs'):
        conf.env.append_unique('VALAFLAGS', ['--define=GIO_2_38'])

    # gio (>=2.34) is necessary for ApplicationCommandLine.get_stdin
    if conf.check_cfg(package='gio-2.0', atleast_version='2.34', mandatory=False, uselib_store='GIO', args='--cflags --libs'):
        conf.env.append_unique('VALAFLAGS', ['--define=GIO_2_34'])

    # gio (>=2.40) is necessary for CLI arguments parsing
    if conf.check_cfg(package='gio-2.0', atleast_version='2.40', mandatory=False, uselib_store='GIO', args='--cflags --libs'):
        conf.env.append_unique('VALAFLAGS', ['--define=GIO_2_40'])

    # gio (>=2.44) is necessary for 'write_all_async' and 'strv_contains'
    if conf.check_cfg(package='gio-2.0', atleast_version='2.44', mandatory=False, uselib_store='GIO', args='--cflags --libs'):
        conf.env.append_unique('VALAFLAGS', ['--define=GIO_2_44'])

    # libsoup (>=2.48) is necessary for the new server API
    if conf.check_cfg(package='libsoup-2.4', atleast_version='2.48', mandatory=False, uselib_store='SOUP', args='--cflags --libs'):
        conf.env.append_unique('VALAFLAGS', ['--define=SOUP_2_48'])

    # libsoup (>=2.50) for steal_connection
    if conf.check_cfg(package='libsoup-2.4', atleast_version='2.50', mandatory=False, uselib_store='SOUP', args='--cflags --libs'):
        conf.env.append_unique('VALAFLAGS', ['--define=SOUP_2_50'])

    # other dependencies
    conf.check(lib='fcgi', uselib_store='FCGI', args='--cflags --libs')

    if conf.options.enable_gcov:
        conf.check(lib='gcov', uselib_store='GCOV', args='--cflags --libs')
        conf.env.append_unique('CFLAGS', ['-fprofile-arcs', '-ftest-coverage'])

    # configure examples
    if conf.options.enable_examples:
        conf.env.ENABLE_EXAMPLES = True
        conf.recurse(glob.glob('examples/*'))

def build(bld):
    bld.shlib(
        packages     = ['glib-2.0', 'gio-2.0', 'libsoup-2.4', 'gee-0.8', 'ctpl', 'fcgi'],
        target       = 'valum',
        gir          = 'Valum-{}'.format(API_VERSION),
        source       = bld.path.ant_glob('src/*.vala'),
        uselib       = ['GLIB', 'GIO', 'CTPL', 'GEE', 'SOUP', 'FCGI', 'GCOV'],
        vapi_dirs    = ['vapi'],
        header_path  = '${INCLUDEDIR}/valum',
        install_path = '${LIBDIR}')

    # pkg-config file
    bld(
        features     = 'subst',
        target       = 'valum.pc',
        source       = ['src/valum.pc.in'],
        install_path = '${LIBDIR}/pkgconfig',
        VERSION      = VERSION,
        API_VERSION  = API_VERSION)

    # RPM specfile
    bld(
        features     = 'subst',
        target       = 'valum.spec',
        source       = ['valum.spec.in'],
        install_path = None,
        VERSION      = VERSION)

    # build examples
    if bld.env.ENABLE_EXAMPLES:
        bld.recurse(glob.glob('examples/*'))

    # build tests
    bld.recurse('tests')

