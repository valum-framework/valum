CC    := gcc
VALAC := valac-0.14
FLAGS := --enable-experimental --thread --vapidir=./vapi/ \
	 --cc=$(CC) --gir Valum-1.0.gir -D BENCHMARK

PKG   := --pkg gio-2.0 --pkg json-glib-1.0 --pkg gee-1.0 \
	 --pkg libsoup-2.4 --pkg libmemcached --pkg luajit \
	 --pkg ctpl

VSRC  := $(shell find 'valum/' -type f -name "*.vala")
CSRC  := $(shell find 'valum/' -type f -name "*.c")
APP   := $(shell find 'app/' -type f -name "*.vala")
EXE   := ./bin/app.valum

all: $(EXE)

run: all
	$(EXE)

drun: debug
	gdb $(EXE)

vdrun: debug
	@`which nemiver` --log-debugger-output $(EXE)

valgrind: debug
	G_SLICE=always-malloc G_DEBUG=gc-friendly  $(shell which valgrind) --tool=memcheck --leak-check=full \
	--leak-resolution=high --num-callers=20 --log-file=vgdump $(EXE)

$(EXE): $(SRC)
	$(VALAC) $(FLAGS) $(PKG) $(VSRC) $(APP) --output $(EXE)

debug:
	@$(MAKE) "FLAGS=$(FLAGS) --debug --save-temps"

genc:
	@$(MAKE) "FLAGS=$(FLAGS) --ccode"

clean:
	rm -f $(CSRC) $(shell find 'valum' -type f -name '*.[co]') $(EXE)

.PHONY= all clean run drun vdrun valgrind debug genc
