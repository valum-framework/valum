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

all: clean $(EXE)

run: all
	$(EXE)

drun: debug
	gdb $(EXE)

$(EXE): $(SRC)
	$(VALAC) $(FLAGS) $(PKG) $(VSRC) $(APP) -o $(EXE)

debug:
	@$(MAKE) "FLAGS=$(FLAGS) -g"

genc:
	@$(MAKE) "FLAGS=$(FLAGS) -C"

clean:
	rm -f $(CSRC) $(shell find 'valum' -type f -name '*.[co]') $(EXE)

.PHONY= all clean
