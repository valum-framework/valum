#!/usr/bin/env python

import glob

APPNAME='valum'
VERSION='0.2.6'
API_VERSION='0.2'

def options(opt):
    opt.load('compiler_c')
    opt.add_option('--enable-examples', action='store_true', default=False, help='build examples')
    opt.recurse('tests')

def configure(conf):
    conf.load('compiler_c vala')

    conf.recurse(['src', 'docs', 'tests'])

    conf.env.append_unique('CFLAGS', ['-Wall',
                                      '-Wno-deprecated-declarations',
                                      '-Wno-unused-variable',
                                      '-Wno-unused-but-set-variable',
                                      '-Wno-unused-function'])

    # configure examples
    if conf.options.enable_examples:
        conf.env.ENABLE_EXAMPLES = True
        conf.recurse(glob.glob('examples/*'))

def build(bld):
    bld.load('compiler_c vala')
    bld.recurse(['src', 'data', 'docs', 'tests'])

    # build examples
    if bld.env.ENABLE_EXAMPLES:
        bld.recurse(glob.glob('examples/*'))
