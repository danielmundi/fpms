.PHONY = all clean distclean install uninstall

CC = gcc
prefix=/usr/local
default_prefix=/usr/local
SRCS := $(wildcard Source/*.c)
install_dir = $(DESTDIR)$(prefix)/share/fpms

LDCFLAGS += -lrt -lpthread

all: NanoHatOLED oled-start fpms.service

NanoHatOLED: $(SRCS)
	# $@ = target (NanoHatOLED); $^ = prerequisites (SRCS files)
	$(CC) $(CPPFLAGS) $(CFLAGS) -o $@ $^ $(LDCFLAGS)

oled-start: NanoHatOLED
	@echo "Create oled-start script"
	$(file > $@,#!/bin/sh)
	$(file >> $@,cd $(install_dir))
	$(file >> $@,./$<)
	chmod +x $@

fpms.service: fpms.service.template
	sed "s#$(default_prefix)#$(prefix)#g" $< >$@

install: NanoHatOLED oled-start fpms.service
	mkdir -p $(install_dir) \
		$(DESTDIR)$(prefix)/bin/oled-start \
		$(DESTDIR)/lib/systemd/system
	cp -rf $(filter-out debian fpms.service fpms.service.template,$(wildcard *)) $(install_dir)
	install oled-start $(DESTDIR)$(prefix)/bin/oled-start
	install fpms.service $(DESTDIR)/lib/systemd/system

clean:
	-rm -f NanoHatOLED
	-rm -f oled-start
	-rm -f fpms.service

distclean: clean

uninstall:
	-rm -rf $(install_dir) \
		$(DESTDIR)$(prefix)/bin/oled-start \
		$(DESTDIR)/lib/systemd/system
