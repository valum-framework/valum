AC_INIT(Valum, 0.1, https://github.com/antono/valum/issues, valum, https://github.com/antono/valum)

AC_CONFIG_HEADERS([config.h])

AM_INIT_AUTOMAKE([1.11] subdir-objects)

AM_SILENT_RULES([yes])

AC_PROG_CC

AM_PROG_AR

AM_PROG_VALAC

LT_INIT

pkg_modules="gobject-2.0 libmemcached libsoup-2.4"
AC_SUBST(pkg_modules)
PKG_CHECK_MODULES(VALUM, libmemcached
ctpl json-glib-1.0 gio-2.0 gee-0.8 luajit [gobject-2.0 libsoup-2.4])

AC_OUTPUT([
        Makefile
        src/valum-0.1.pc
        src/Makefile
])
