# ##########################################################################
# Copyright (c) 2016-present, Yann Collet, Facebook, Inc.
# All rights reserved.
#
# This Makefile is validated for Linux, macOS, *BSD, Hurd, Solaris, MSYS2 targets
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
# ##########################################################################

# Version numbers
LIBVER_MAJOR := 5
LIBVER_MINOR := 6
LIBVER_PATCH := 0
LIBVER := 560
VERSION?= $(LIBVER)

CPPFLAGS+= -I.
CFLAGS  ?= -O0
DEBUGFLAGS = -g -Wall -Wextra -Wshadow -DDEBUG \
           -Wstrict-aliasing=1 -Wswitch-enum -Wdeclaration-after-statement \
           -Wstrict-prototypes -Wundef -Wpointer-arith -Wformat-security
CFLAGS  += $(DEBUGFLAGS)
FLAGS    = $(CPPFLAGS) $(CFLAGS)4hc


LZ4HC_FILES := lz4hc.c


LZ4HC_OBJ   := $(patsubst %.c,%.o,$(LZ4HC_FILES))

SONAME_FLAGS = -Wl,-soname=liblz4hc.$(SHARED_EXT).$(LIBVER_MAJOR)
SHARED_EXT = so
SHARED_EXT_MAJOR = $(SHARED_EXT).$(LIBVER_MAJOR)
SHARED_EXT_VER = $(SHARED_EXT).$(LIBVER)


LIBLZ4HC = liblz4hc.$(SHARED_EXT_VER)


.PHONY: all clean install uninstall

all: lib

liblz4hc.a: ARFLAGS = rcs
liblz4hc.a: $(LZ4HC_OBJ)
	@echo compiling static library
	@$(AR) $(ARFLAGS) $@ $^

lib: liblz4hc.a

clean:
	@$(RM) core *.o *.a *.gcda *.$(SHARED_EXT) *.$(SHARED_EXT).* liblz4hc.pc
	@echo Cleaning library completed

#-----------------------------------------------------------------------------
# make install is validated only for Linux, OSX, BSD, Hurd and Solaris targets
#-----------------------------------------------------------------------------
ifneq (,$(filter $(shell uname),Linux Darwin GNU/kFreeBSD GNU OpenBSD FreeBSD NetBSD DragonFly SunOS))

ifneq (,$(filter $(shell uname),SunOS))
INSTALL ?= ginstall
else
INSTALL ?= install
endif

PREFIX     ?= /usr/local
DESTDIR    ?=
LIBDIR     ?= $(PREFIX)/lib
INCLUDEDIR ?= $(PREFIX)/include

ifneq (,$(filter $(shell uname),OpenBSD FreeBSD NetBSD DragonFly))
PKGCONFIGDIR ?= $(PREFIX)/libdata/pkgconfig
else
PKGCONFIGDIR ?= $(LIBDIR)/pkgconfig
endif

INSTALL_LIB  ?= $(INSTALL) -m 755
INSTALL_DATA ?= $(INSTALL) -m 644


liblz4hc.pc:
liblz4hc.pc: liblz4hc.pc.in
	@echo creating pkgconfig
	@sed -e 's|@PREFIX@|$(PREFIX)|' \
             -e 's|@LIBDIR@|$(LIBDIR)|' \
             -e 's|@INCLUDEDIR@|$(INCLUDEDIR)|' \
             -e 's|@VERSION@|$(VERSION)|' \
             $< >$@

install: liblz4hc.a
	@$(INSTALL) -d -m 755 $(DESTDIR)$(PKGCONFIGDIR)/ $(DESTDIR)$(INCLUDEDIR)/
	@echo Installing libraries
	@$(INSTALL_LIB) liblz4hc.a $(DESTDIR)$(LIBDIR)

	@echo Installing includes
	@$(INSTALL_DATA) lz4hc.h $(DESTDIR)$(INCLUDEDIR)

uninstall:
	@$(RM) $(DESTDIR)$(LIBDIR)/liblz4hc.a
	@$(RM) $(DESTDIR)$(PKGCONFIGDIR)/liblz4hc.pc
	@$(RM) $(DESTDIR)$(INCLUDEDIR)/lz4hc.h
	@echo zstd libraries successfully uninstalled

endif
