#!/usr/bin/env python

VERSION=(0,1,0)
APPNAME='valum'

top='.'
out='build'

def options(opt):
    opt.load('compiler_c vala')

def configure(conf):
    conf.load('compiler_c vala')

    conf.check_cfg(package='glib', mandatory=True)
    conf.check_cfg(package='ctpl', mandatory=True, uselib_store='CTPL', args='--cflags --libs')
    conf.check_cfg(package='gee-0.8', mandatory=True, uselib_store='GEE', args='--cflags --libs')
    conf.check_cfg(package='libsoup-2.4', mandatory=True, uselib_store='SOUP', args='--cflags --libs')

    # optionals packages
    conf.check_cfg(package='libmemcached', uselib_store='MEMCACHED', args='--cflags --libs')
    conf.check_cfg(package='luajit', uselib_store='LUA', args='--cflags --libs')

def build(bld):
    # build a static library
    bld.stlib(
        packages    = ['glib-2.0', 'libsoup-2.4', 'gee-0.8', 'ctpl'],
        target      = 'valum-{}.{}'.format(*VERSION),
        gir         = 'Valum-{}.{}'.format(*VERSION),
        source      = bld.path.ant_glob('src/**/*.vala'),
        uselib      = ['CTPL', 'GEE', 'SOUP'],
        vapi_dirs   = ['vapi'])

    # build the sample application
    bld.program(
       packages     = ['libsoup-2.4', 'gee-0.8', 'ctpl', 'lua', 'libmemcached'],
       target       = 'valum',
       use          = 'valum-{}.{}'.format(*VERSION),
       source       = bld.path.ant_glob('app/**/*.vala'),
       uselib       = ['CTPL', 'GEE', 'SOUP', 'LUA', 'MEMCACHED'],
       vapi_dirs    = ['vapi'])
