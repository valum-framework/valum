#!/usr/bin/env python

import glob

APPNAME='valum'
VERSION='0.2.6'
API_VERSION='0.2'

def options(opt):
    opt.load('compiler_c')
    opt.add_option('--enable-docs', action='store_true', default=False, help='generate user documentation')
    opt.add_option('--enable-examples', action='store_true', default=False, help='build examples')
    opt.recurse('tests')

def configure(conf):
    conf.load('compiler_c vala')

    conf.check_vala(min_version=(0,26,0))

    conf.env.append_unique('CFLAGS', ['-Wall',
                                      '-Wno-deprecated-declarations',
                                      '-Wno-unused-variable',
                                      '-Wno-unused-but-set-variable',
                                      '-Wno-unused-function'])
    conf.env.append_unique('VALAFLAGS', ['--target-glib=2.32',
                                         '--enable-experimental',
                                         '--enable-deprecated',
                                         '--fatal-warnings'])

    conf.recurse('src tests')

    if conf.options.enable_docs:
        conf.env.ENABLE_DOCS = True
        conf.recurse('docs')

    # configure examples
    if conf.options.enable_examples:
        conf.env.ENABLE_EXAMPLES = True
        conf.recurse(glob.glob('examples/*'))

def build(bld):
    bld.load('compiler_c vala')
    bld.recurse('src data tests')

    if bld.env.ENABLE_DOCS:
        bld.recurse('docs')

    # build examples
    if bld.env.ENABLE_EXAMPLES:
        bld.recurse(glob.glob('examples/*'))
