ifeq ($(DESTINATION_PREFIX),)
#    DESTINATION_PREFIX = $(HOME)/.local/share/icons
     DESTINATION_PREFIX = result
endif


SHELL:=/bin/bash

TAR_TARGET:=target/tar/
SOURCE_PREFIX:=src/
FRIENDLY_NAME:=oxylite-and-crystal-remix-icon-theme

# CONTRIBUTORS: update this list when a new 'category' of icons is made
ICONDIR_LIST:=actions apps categories devices emblems emotes mimetypes places status ui
FILES_OUTSIDE_SOURCE_PREFIX:=README CONTRIBUTORS licenses.yaml

# tar_png directive inserts custom code in the d loop
# make will expand the $(BUILD) variable then pass this to bash
# Then, bash will expand $${lambda}
#
# FIXME: add feedback like 'making tarball' and 'moving src files'
BUILD:=( \
mkdir -p "$(TAR_TARGET)"; \
\
for icondir in $(ICONDIR_LIST); do \
    cp -a "$(SOURCE_PREFIX)"/"$${icondir}" "$(TAR_TARGET)"/"$${icondir}"; \
    \
    eval $${lambda}; \
    \
done; \
cp $(FILES_OUTSIDE_SOURCE_PREFIX) "$(TAR_TARGET)"; \
cp $$(find src -maxdepth 1 -type f) "$(TAR_TARGET)"; \
\
tar -c --owner=0 --group=0 \
    --mode='u=rwX,g=rX,o=rX' \
    --mtime="$$(date -Iseconds)" \
    $(TAR_TARGET) \
        | gzip -9 > "target/$(FRIENDLY_NAME)".tar.gz; \
    ls -R "$(TAR_TARGET)" \
	&& echo -e '\n========\nMakefile: BUILD: You may verify the contents of $(TAR_TARGET)' \
)

.PHONY: all tar tar_png install clean

all: tarball

tarball: clean
	@$(BUILD)

# in the line 'for * in …' we need to send the literal '${icondir} to the BUILD subshell
#
# for each file in src/icondir, if it is an svg, then use rsvg-convert otherwise copy it as-is and replace .svg$ with .png
# FIXME: refactor export line across multiple lines (ending each line with \ or \\ give a bash: unexpected EOF while looking for matching `''. \\ seems to be worse: see issue #1)
# jackharro: I'm using find instead of for because for [[ -f "$(TAR_TARGET)"/"$${icondir}" ]] doesn't work
png: clean
	@echo 'Makefile: info: Will convert svg to png during build'
	export lambda='for all_files in "$(TAR_TARGET)"/"$${icondir}"; do if [[ -f $${all_files} ]] ; then ; if [[ $${all_files} ~= (.+)\.svg ]] ; then ;  --output
	$(BUILD)
	
install:
	-mkdir -p "$(DESTINATION_PREFIX)"
	cp "target/$(FRIENDLY_NAME).tar.gz" "$(DESTINATION_PREFIX)" \
	    || echo 'Makefile: install: fatal: remember to `make [tarball]` or `make png` before `make install`'
	

clean:
	-rm -r target result

