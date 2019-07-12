flex: $(ANDROID_BUILD_DIR)/flex.done
flex-host: $(HOST_OUT_DIR)/bin/flex
fetch-sources: flex/sources
remove-sources: remove-flex-sources

# we need to download sources if source path is not specified
ifeq ($(FLEX_SOURCES),)
FLEX_SOURCES = $(abspath flex/sources)
$(HOST_BUILD_DIR)/flex: flex/sources
$(ANDROID_BUILD_DIR)/flex: flex/sources
endif

$(ANDROID_BUILD_DIR)/flex.done: $(ANDROID_BUILD_DIR)/flex
	cd $(ANDROID_BUILD_DIR)/flex && make -j $(THREADS)
	cd $(ANDROID_BUILD_DIR)/flex/src && make install-libLTLIBRARIES install-binPROGRAMS install-includeHEADERS
	touch $@

# checked in configure script won't do, we need to rerun autoreconf
$(ANDROID_BUILD_DIR)/flex: $(ANDROID_TOOLCHAIN_DIR) | $(ANDROID_BUILD_DIR)
	-mkdir $@
	cd $@ && $(FLEX_SOURCES)/configure $(ANDROID_EXTRA_CONFIGURE_FLAGS)

$(HOST_OUT_DIR)/bin/flex: $(HOST_BUILD_DIR)/flex.done

$(HOST_BUILD_DIR)/flex.done: $(HOST_BUILD_DIR)/flex
	cd $(HOST_BUILD_DIR)/flex && make install -j $(THREADS)
	touch $@

$(HOST_BUILD_DIR)/flex: | $(HOST_BUILD_DIR)
	-mkdir $@
	cd $@ && $(FLEX_SOURCES)/configure --prefix=$(abspath $(HOST_OUT_DIR))

FLEX_COMMIT_HASH = 98018e3f58d79e082216d406866942841d4bdf8a
FLEX_REPO = https://github.com/westes/flex.git

flex/sources:
	git clone $(FLEX_REPO) flex/sources
	cd flex/sources && git checkout $(FLEX_COMMIT_HASH)
# checked in configure script won't do, we need to rerun autoreconf
	cd flex/sources && autoreconf -i -f

.PHONY: remove-flex-sources
remove-flex-sources:
	rm -rf flex/sources
