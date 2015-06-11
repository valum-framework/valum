#!/usr/bin/env python

import glob

APPNAME='valum'
VERSION='0.1.3-alpha'
API_VERSION='0.1'

top='.'
out='build'

def options(opt):
    opt.load('compiler_c')

    opt.add_option('--enable-gcov', action='store_true', default=False, help='enable coverage with gcov')
    opt.add_option('--enable-threading', action='store_true', default=False, help='enable threading support with GThread')

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

    # gio (>=2.40) is necessary for CLI arguments parsing
    if conf.check_cfg(package='gio-2.0', atleast_version='2.40', mandatory=False, uselib_store='GIO', args='--cflags --libs'):
        conf.env.append_unique('VALAFLAGS', ['--define=GIO_2_40'])

    # libsoup (>=2.48) is necessary for the new server API
    if conf.check_cfg(package='libsoup-2.4', atleast_version='2.48', mandatory=False, uselib_store='SOUP', args='--cflags --libs'):
        conf.env.append_unique('VALAFLAGS', ['--define=SOUP_2_48'])

    # other dependencies
    conf.check(lib='fcgi', uselib_store='FCGI', args='--cflags --libs')

    if conf.options.enable_gcov:
        conf.check(lib='gcov', uselib_store='GCOV', args='--cflags --libs')
        conf.env.append_unique('CFLAGS', ['-fprofile-arcs', '-ftest-coverage'])

    if conf.options.enable_threading:
        conf.check_cfg(package='gthread-2.0', atleast_version='2.32')
        conf.env.append_unique('VALAFLAGS', ['--thread'])

    # configure examples
    conf.recurse(glob.glob('examples/*'))

def build(bld):
    # build a static library
    bld.shlib(
        packages     = ['glib-2.0', 'libsoup-2.4', 'gee-0.8', 'ctpl', 'fcgi'],
        name         = 'valum',
        target       = 'valum-{}'.format(API_VERSION),
        gir          = 'Valum-{}'.format(API_VERSION),
        source       = bld.path.ant_glob('src/**/*.vala'),
        uselib       = ['GLIB', 'GIO', 'CTPL', 'GEE', 'SOUP', 'FCGI', 'GCOV'],
        vapi_dirs    = ['vapi'],
        install_path = '${LIBDIR}')

    # pkg-config file
    bld(
        features     = 'subst',
        target       = 'valum-{}.pc'.format(API_VERSION),
        source       = ['src/valum.pc.in'],
        install_path = '${LIBDIR}/pkgconfig',
        VERSION      = VERSION,
        API_VERSION  = API_VERSION)

    # build examples
    bld.recurse(glob.glob('examples/*'))

    # build tests
    bld.recurse('tests')

