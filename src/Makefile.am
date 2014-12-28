AM_CFLAGS = -Wall -g

AM_CPPFLAGS = $(CTPL_CFLAGS) \
			  $(GEE_CFLAGS) \
			  $(GLIB_CFLAGS) \
			  $(LIBMEMCACHED_CFLAGS) \
			  $(LIBSOUP_CFLAGS) \
			  $(LUAJIT_CFLAGS) \
			  $(GIO_CFLAGS)

bin_PROGRAMS = valum

valumdir = $(datadir)/valum
dist_valum_DATA = templates/home.html \
				  haml.lua \
				  hello.lua \
				  lua.haml \
				  main.gs

valum_SOURCES =  app.vala nosql/memcached.vala script/lua.vala

valum_VALAFLAGS =  --vapidir=. \
				   --pkg libmemcached --pkg libsoup-2.4 --pkg gee-0.8 \
				   --pkg json-glib-1.0 --pkg lua --pkg ctpl --pkg valum-0.1 \
				   --thread --enable-experimental

valum_LDADD = libvalum.la \
			  $(LIBMEMCACHED_LIBS) \
			  $(LUAJIT_LIBS) \
			  $(GLIB_LIBS) \
			  $(GIO_LIBS)

lib_LTLIBRARIES = libvalum.la

vapidir = $(datadir)/vala/vapi
dist_vapi_DATA = valum-0.1.vapi valum-0.1.deps

libvalum_la_SOURCES = request.vala response.vala router.vala route.vala \
					  view/tpl.vala view/view.vala
libvalum_la_LDFLAGS =

libvalum_la_LIBADD = $(LIBVALUM_LIBS) \
					 $(GEE_LIBS) \
					 $(DBUS_GLIB_LIBS) \
					 $(CTPL_LIBS) \
					 $(GLIB_LIBS) \
					 $(LIBSOUP_LIBS)

libvalum_la_VALAFLAGS = --vapidir=. \
						--pkg libsoup-2.4 --pkg ctpl --pkg gee-0.8 \
						--library valum-0.1 -H valum.h \
						--vapi valum-0.1.vapi

valumincludedir = $(includedir)/valum-0.1
valuminclude_HEADERS = valum.h

pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = valum-0.1.pc

EXTRA_DIST = valum-0.1.pc.in
