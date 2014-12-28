## Process this file with automake to produce Makefile.in

## Created by Anjuta

AM_CPPFLAGS = \
	-DPACKAGE_LOCALE_DIR=\""$(localedir)"\" \
	-DPACKAGE_SRC_DIR=\""$(srcdir)"\" \
	-DPACKAGE_DATA_DIR=\""$(pkgdatadir)"\" \
	$(VALUM_CFLAGS)

AM_CFLAGS = -Wall -g

lib_LTLIBRARIES = libvalum.la

vapidir = $(datadir)/vala/vapi
dist_vapi_DATA = valum-0.1.vapi valum-0.1.deps

libvalum_la_SOURCES = request.vala response.vala router.vala route.vala
libvalum_la_LDFLAGS =
libvalum_la_LIBADD = $(VALUM_LIBS)

libvalum_la_VALAFLAGS =  --vapidir ./vapi --pkg libmemcached --pkg libsoup-2.4 \
	--pkg gee-0.8 --pkg libsoup-2.4 --pkg json-glib-1.0 --library valum-0.1 \
	--vapi valum-0.1.vapi -H valum.h

valumincludedir = $(includedir)/valum-0.1
valuminclude_HEADERS = valum.h

pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = valum-0.1.pc

EXTRA_DIST = \
	valum-0.1.pc.in
