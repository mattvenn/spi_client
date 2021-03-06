all: check_latest ci-deps test

TARGETDIR:=$(HOME)/toolchain
SOURCEDIR:=$(HOME)/src

test: 
	grep . $(TARGETDIR)/*.ver
	$(MAKE) -s -C verilog test

clean:
	$(MAKE) -C verilog clean

GIT_YOSYS:=https://github.com/cliffordwolf/yosys.git
GIT_SYMBI:=https://github.com/cliffordwolf/SymbiYosys.git
GIT_YICES:=https://github.com/SRI-CSL/yices2.git

VER_YOSYS:=$(TARGETDIR)/yosys.ver
VER_SYMBI:=$(TARGETDIR)/symbiyosys.ver
VER_YICES:=$(TARGETDIR)/yices2.ver

check_latest:
	[ -e $(VER_YOSYS) ] && ( git ls-remote --heads $(GIT_YOSYS) refs/heads/master | cut -f1 | cmp $(VER_YOSYS) - || rm -f $(VER_YOSYS) ) || true
	[ -e $(VER_SYMBI) ] && ( git ls-remote --heads $(GIT_SYMBI) refs/heads/master | cut -f1 | cmp $(VER_SYMBI) - || rm -f $(VER_SYMBI) ) || true
	[ -e $(VER_YICES) ] && ( git ls-remote --heads $(GIT_YICES) refs/heads/master | cut -f1 | cmp $(VER_YICES) - || rm -f $(VER_YICES) ) || true	

ci-deps: $(VER_YOSYS) $(VER_SYMBI) $(VER_YICES)

ifndef TRAVIS
  NPROC:= -j$(shell nproc)
endif

$(VER_YOSYS):
	mkdir -p $(SOURCEDIR); cd $(SOURCEDIR) && \
	( [ -e yosys ] || git clone $(GIT_YOSYS) ) && \
	cd yosys && \
	git pull && \
	git log -1 && \
	nice make $(NPROC) PREFIX=$(TARGETDIR) install && \
	git rev-parse HEAD > $(VER_YOSYS)

$(VER_SYMBI):
	mkdir -p $(SOURCEDIR); cd $(SOURCEDIR) && \
	( [ -e SymbiYosys ] || git clone $(GIT_SYMBI) ) && \
	cd SymbiYosys && \
	git pull && \
	git log -1 && \
	nice make PREFIX=$(TARGETDIR) install && \
	git rev-parse HEAD > $(VER_SYMBI)

$(VER_YICES):
	mkdir -p $(SOURCEDIR); cd $(SOURCEDIR) && \
	( [ -e yices2 ] || git clone $(GIT_YICES) ) && \
	cd yices2 && \
	git pull && \
	git log -1 && \
	autoconf && \
	./configure --prefix=$(TARGETDIR) && \
	nice make $(NPROC) && \
	make $(NPROC) install && \
	git rev-parse HEAD > $(VER_YICES)

.PHONY: test clean ci-deps check_latest
