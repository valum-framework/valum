VER    := 0.1
CC     := gcc
VALAC  := valac-0.14

EXE   := ./build/app.valum
LIB   := ./build/libvalum_$(VER).so
GIR   := Valum-$(VER).gir
HDR   := ./build/valum_$(VER).h
VAPI  := ./vapi/valum-$(VER)


FLAGS  := --enable-experimental --thread --vapidir=./vapi/ \
	  --cc=$(CC) -D BENCHMARK

LFLAGS := -X -fPIC -X -shared --gir=$(GIR) --library=$(VAPI) \
	  --header=$(HDR) --output=$(LIB)

AFLAGS := -X $(LIB) -X -I./build/ --output=$(EXE)

PKGS   := --pkg gio-2.0 --pkg json-glib-1.0 --pkg gee-1.0 \
	  --pkg libsoup-2.4 --pkg libmemcached --pkg luajit \
	  --pkg ctpl

LSRC   := $(shell find 'src/' -type f -name "*.vala")
CSRC   := $(shell find 'src/' -type f -name "*.c")
ASRC   := $(shell find 'app/' -type f -name "*.vala")


$(EXE): $(LIB)
	$(VALAC) $(FLAGS) $(AFLAGS) $(VAPI).vapi $(ASRC) $(PKGS)

$(LIB):
	$(VALAC) $(FLAGS) $(LFLAGS) $(PKGS) $(LSRC)

all: $(LIB) $(EXE)

run: all
	$(EXE)

drun: debug
	gdb $(EXE)

vdrun: debug
	@`which nemiver` --log-debugger-output $(EXE)

valgrind: debug
	G_SLICE=always-malloc G_DEBUG=gc-friendly $(shell which valgrind) --tool=memcheck --leak-check=full \
	--leak-resolution=high --num-callers=20 --log-file=vgdump $(EXE)

debug: clean
	@$(MAKE) "FLAGS=$(FLAGS) --debug --save-temps"

genc:
	@$(MAKE) "FLAGS=$(FLAGS) --ccode"

clean:
	rm -f $(CSRC) ./build/* ./vapi/valum-*

.PHONY= all clean run drun vdrun valgrind debug genc
