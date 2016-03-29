custom_target('docs',
              command: [find_program('sphinx-build'), '-W', '-b', 'html', '@INPUT@', '@OUTPUT@'],
              input: '.',
              output: '.',
              build_always: true)
