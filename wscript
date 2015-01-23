#!/usr/bin/env python

import glob

VERSION=(0,1,0)
APPNAME='valum'

top='.'
out='build'

def options(opt):
    opt.load('compiler_c vala')

def configure(conf):
    conf.load('compiler_c vala')

    # TODO: add a check for fcgi
    conf.check_cfg(package='glib', mandatory=True)
    conf.check_cfg(package='ctpl', mandatory=True, uselib_store='CTPL', args='--cflags --libs')
    conf.check_cfg(package='gee-0.8', mandatory=True, uselib_store='GEE', args='--cflags --libs')
    conf.check_cfg(package='libsoup-2.4', mandatory=True, uselib_store='SOUP', args='--cflags --libs')

    # optionals packages
    conf.check_cfg(package='libmemcached', uselib_store='MEMCACHED', args='--cflags --libs')
    conf.check_cfg(package='luajit', uselib_store='LUA', args='--cflags --libs')

def build(bld):
    bld.shlib(
        packages    = ['glib-2.0', 'libsoup-2.4', 'gee-0.8', 'ctpl', 'fcgi'],
        features    = 'c',
        target      = 'valum-{}.{}'.format(*VERSION),
        source      = glob.glob('src/*.vala') + glob.glob('src/**/*.vala'),
        lib         = ['fcgi'],
        gir         = 'Valum-{}.{}'.format(*VERSION),
        pkg_name    = 'valum',
        uselib      = ['CTPL', 'GEE', 'SOUP'],
        vapi_dirs   = ['vapi'],
        vala_define = ['BENCHMARK'])

    # build the sample application
    # TODO: build against a static library
    bld.program(
       packages     = ['libsoup-2.4', 'gee-0.8', 'lua', 'libmemcached', 'valum-{}.{}'.format(*VERSION)],
       target       = 'valum',
       use          = ['valum-{}.{}'.format(*VERSION)],
       source       = glob.glob('app/*.vala') + glob.glob('app/**/*.vala'),
       uselib       = ['CTPL', 'GEE', 'SOUP', 'LUA', 'MEMCACHED'],
       vapi_dirs    = ['build', 'vapi'],
       thread       = True,
       experimental = True)

    # build the FastCGI application
    bld.program(
       packages     = ['libsoup-2.4', 'gee-0.8', 'lua', 'libmemcached', 'valum-{}.{}'.format(*VERSION)],
       target       = 'valum.fcg',
       use          = ['valum-{}.{}'.format(*VERSION)],
       source       = glob.glob('app/*.vala') + glob.glob('app/**/*.vala'),
       uselib       = ['CTPL', 'GEE', 'SOUP', 'LUA', 'MEMCACHED'],
       vapi_dirs    = ['build', 'vapi'],
       thread       = True,
       experimental = True,
       vala_define = ['FCGI'])
