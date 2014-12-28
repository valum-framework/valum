SUBDIRS = src tests

bin_PROGRAMS = valum

valumdir = $(datadir)/valum
dist_valum_DATA = app/templates/home.html \
				  app/haml.lua \
				  app/hello.lua \
				  app/lua.haml \
				  app/main.gs

valum_SOURCES =  app/app.vala app/nosql/memcached.vala app/script/lua.vala

valum_VALAFLAGS =  --vapidir=src/vapi \
				   --pkg libmemcached --pkg libsoup-2.4 --pkg gee-0.8 \
				   --pkg json-glib-1.0 --pkg lua --pkg ctpl --pkg valum-0.1 \
				   --thread --enable-experimental

valum_LDADD = src/libvalum.la \
	$(GLIB_LIBS) \
	$(GEE_LIBS) \
	$(LIBSOUP_LIBS) \
	$(LUAJIT_LIBS) \
	$(LIBMEMCACHED_LIBS)

AM_CPPFLAGS = -I src \
			  $(GLIB_CFLAGS) \
			  $(GEE_CFLAGS) \
			  $(LIBSOUP_CFLAGS) \
			  $(LUAJIT_CFLAGS) \
			  $(LIBMEMCACHED_CFLAGS) 

dist_doc_DATA = \
	README.md \
	COPYING \
	AUTHORS \
	ChangeLog \
	INSTALL \
	NEWS \
	TODO.md

# Remove doc directory on uninstall
uninstall-local:
	-rm -r $(docdir)

