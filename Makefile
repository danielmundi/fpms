.PHONY = all clean distclean install uninstall

CC = gcc
prefix=/usr/local
default_prefix=/usr/local
SRCS := $(wildcard Source/*.c)
install_dir = $(DESTDIR)$(prefix)/share/fpms

LDCFLAGS += -lrt -lpthread

all: NanoHatOLED

NanoHatOLED: $(SRCS)
	# $@ = target (NanoHatOLED); $^ = prerequisites (SRCS files)
	$(CC) $(CPPFLAGS) $(CFLAGS) -o $@ $^ $(LDCFLAGS)

install: NanoHatOLED
	mkdir -p $(install_dir) \
		$(DESTDIR)$(prefix)/bin/oled-start \
		$(DESTDIR)/lib/systemd/system
	cp -rf $(filter-out debian fpms.service fpms.service.template,$(wildcard *)) $(install_dir)
	# Correct the prefix on fpms.service ExecStart
	sed "s#$(default_prefix)#$(prefix)#g" fpms.service.template > fpms.service
	install fpms.service $(DESTDIR)/lib/systemd/system

clean:
	-rm -f NanoHatOLED
	-rm -f fpms.service

distclean: clean

uninstall:
	-rm -rf $(install_dir) \
		$(DESTDIR)/lib/systemd/system
