custom_target('docs',
              command: [find_program('sphinx-build-3'), '-W', '-b', 'html', '@INPUT@', '@OUTPUT@'],
              input: '.',
              output: '.',
              build_always: true)
