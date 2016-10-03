sphinx = find_program('sphinx-build-3', required: false)
if not sphinx.found()
    sphinx = find_program('sphinx-build', required: false)
endif

# Generate '*.pot' files for translators
custom_target('translations', command: [sphinx, '-W', '-b', 'gettext', '@INPUT@', '@OUTPUT@'],
              input: '.',
              output: 'pot')

foreach lang : ['en', 'fr']
    custom_target('@0@ documentation'.format(lang),
                  command: [sphinx, '-W', '-b', 'html', '-D', 'language=@0@'.format(lang), '@INPUT@', '@OUTPUT@'],
                  input: '.',
                  output: lang)
endforeach
