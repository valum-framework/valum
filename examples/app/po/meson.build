xgettext = find_program('xgettext')
custom_target(
    'messages.pot',
    command: [xgettext, '-o', '@OUTPUT@', '@INPUT@'],
    input: app_sources,
    output: 'messages.pot',
    build_always: true,
)
i18n = import('i18n')
i18n.gettext('app', languages: ['en', 'fr'])
