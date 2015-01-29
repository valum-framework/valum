#!/usr/bin/env python

import glob

APPNAME='valum'
VERSION='0.1.0-alpha'
API_VERSION='0.1'

top='.'
out='build'

def options(opt):
    opt.load('compiler_c')

def configure(conf):
    conf.load('compiler_c vala')

    #conf.env.append_unique('VALAFLAGS', ['--enable-experimental-non-null'])

    conf.check_cfg(package='glib', mandatory=True)
    conf.check_cfg(package='glib-2.0', atleast_version='2.32', mandatory=True, uselib_store='GLIB', args='--cflags --libs')
    conf.check_cfg(package='gio-2.0', atleast_version='2.32', uselib_store='GIO', args='--cflags --libs')
    conf.check_cfg(package='ctpl', atleast_version='0.3.3', mandatory=True, uselib_store='CTPL', args='--cflags --libs')
    conf.check_cfg(package='gee-0.8', atleast_version='0.6.4', mandatory=True, uselib_store='GEE', args='--cflags --libs')
    conf.check_cfg(package='libsoup-2.4', atleast_version='2.38', mandatory=True, uselib_store='SOUP', args='--cflags --libs')

    # libfcgi does not provide a .pc file...
    conf.check(lib='fcgi', mandatory=True, uselib_store='FCGI', args='--cflags --libs')

    # configure examples
    conf.recurse(glob.glob('examples/*'))

def build(bld):
    # build a static library
    bld.stlib(
        packages     = ['glib-2.0', 'libsoup-2.4', 'gee-0.8', 'ctpl', 'fcgi'],
        name         = 'valum',
        target       = 'valum-{}'.format(API_VERSION),
        gir          = 'Valum-{}'.format(API_VERSION),
        source       = bld.path.ant_glob('src/**/*.vala'),
        uselib       = ['GLIB', 'GIO', 'CTPL', 'GEE', 'SOUP', 'FCGI'],
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

    # build examples recursively
    bld.recurse(glob.glob('examples/*'))

    # build tests
    bld.recurse('tests')
