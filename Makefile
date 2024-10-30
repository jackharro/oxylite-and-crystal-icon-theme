ifeq ($(DESTINATION_PREFIX),)
#    DESTINATION_PREFIX = $(HOME)/.local/share/icons
     DESTINATION_PREFIX = result
endif


SHELL:=/bin/bash

TAR_TARGET:=target/tar/
SOURCE_PREFIX:=src/
FRIENDLY_NAME:=oxylite-and-crystal-remix-icon-theme

# CONTRIBUTORS: update this list when a new 'category' of icons is made
FILES_OUTSIDE_SOURCE_PREFIX:=README CONTRIBUTORS licenses.yaml

.PHONY: all tar tar_png install clean build

all: svg

svg: build
	ls -R "$(TAR_TARGET)" && \
	echo -e '\n========\nMakefile: svg: You may verify the contents of $(TAR_TARGET)'
	
# for each file in each icondir, rename .svg to .png and convert each svg to a png:
png: build
	cd "$(TAR_TARGET)" ; \
	find . -type f -name *.svg -exec echo $(SHELL) -c mv {} "$$(dirname {})/$$(basename {} .svg)".png \; ; \
	find . -type f -name *.png -exec echo $(SHELL) -c file {} | grep -n SVG && "mv {} "$$(dirname {})/$$(basename {} .png)" && svg2png "$$(dirname {})/$$(basename {} .png) \; ; \
	read

install:
	@test -e target || (echo -e 'Makefile: install: fatal: no built icon archive\n    hint: use `make [svg]|png` to build an icon archive, then try installing again' && exit 1)
	-mkdir -p "$(DESTINATION_PREFIX)"
	cp "target/$(FRIENDLY_NAME).tar.gz" "$(DESTINATION_PREFIX)"

build: clean
	mkdir -p "$(TAR_TARGET)"; \
	cp -r "$(SOURCE_PREFIX)"/* "$(TAR_TARGET)"
	cp $(FILES_OUTSIDE_SOURCE_PREFIX) "$(TAR_TARGET)"
	cp $$(find src -maxdepth 1 -type f) "$(TAR_TARGET)"
	\
	tar -c --owner=0 --group=0 \
	    --mode='u=rwX,g=rX,o=rX' \
	    --mtime="$$(date -Iseconds)" \
	    $(TAR_TARGET) | \
		gzip -9 > "target/$(FRIENDLY_NAME)".tar.gz;
	    

clean:
	@echo Makefile: clean: info: ignore errors resulting from rm 
	-rm -r target result

