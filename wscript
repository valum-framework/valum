#!/usr/bin/env python

import glob

APPNAME='valum'

VERSION=(0,1,0)
API_VERSION='.'.join(map(str,VERSION))

top='.'
out='build'

def options(opt):
    opt.load('compiler_c')

def configure(conf):
    conf.load('compiler_c vala')

    # conf.env.append_unique('VALAFLAGS', ['--enable-experimental-non-null'])

    conf.check_cfg(package='glib-2.0', atleast_version='2.32', uselib_store='GLIB', args='--cflags --libs')
    conf.check_cfg(package='gio-2.0', atleast_version='2.32', uselib_store='GIO', args='--cflags --libs')
    conf.check_cfg(package='ctpl', atleast_version='0.3.3', uselib_store='CTPL', args='--cflags --libs')
    conf.check_cfg(package='gee-0.8', atleast_version='0.6.4', uselib_store='GEE', args='--cflags --libs')
    conf.check_cfg(package='libsoup-2.4', atleast_version='2.38', uselib_store='SOUP', args='--cflags --libs')
    conf.check_cfg(package='uuid', atleast_version='2.20', uselib_store='UUID', args='--cflags --libs')

    conf.check(lib='fcgi', uselib_store='FCGI', args='--cflags --libs')

    # configure examples
    conf.recurse(glob.glob('examples/*'))

def build(bld):
    # build a static library
    bld.stlib(
        packages     = ['glib-2.0', 'libsoup-2.4', 'gee-0.8', 'ctpl', 'fcgi', 'uuid'],
        name         = 'valum',
        target       = 'valum-{}.{}'.format(*VERSION),
        gir          = 'Valum-{}.{}'.format(*VERSION),
        source       = bld.path.ant_glob('src/**/*.vala'),
        uselib       = ['GLIB', 'GIO', 'CTPL', 'GEE', 'SOUP', 'FCGI', 'UUID'],
        vapi_dirs    = ['vapi'],
        install_path = '${LIBDIR}')

    # pkg-config file
    bld(
        features     = 'subst',
        target       = 'valum-{}.{}.pc'.format(*VERSION),
        source       = ['src/valum.pc.in'],
        install_path = '${LIBDIR}/pkgconfig',
        VERSION      = API_VERSION,
        MAJOR        = str(VERSION[0]),
        MINOR        = str(VERSION[1]))

    # build examples recursively
    bld.recurse(glob.glob('examples/*'))

    # build tests
    bld.recurse('tests')
