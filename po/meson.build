languages = ['fr']

xgettext = find_program('xgettext', required: false)
if xgettext.found()
    custom_target('messages.pot', command: [xgettext, '-o', '@OUTPUT@', '@INPUT@'],
                  input: vsgi_sources + valum_sources,
                  output: 'messages.pot',
                  build_always: true)
endif

i18n = import('i18n')
i18n.gettext('vsgi-@0@'.format(api_version), languages: languages)
i18n.gettext('valum-@0@'.format(api_version), languages: languages)
