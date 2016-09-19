sphinx = find_program('sphinx-build-3', required: false)
if not sphinx.found()
    sphinx = find_program('sphinx-build')
endif
custom_target('docs',
              command: [sphinx, '-W', '-b', 'html', '@INPUT@', '@OUTPUT@'],
              input: '.',
              output: '.',
              build_always: true)
