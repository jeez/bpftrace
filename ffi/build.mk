ffi: $(ANDROID_BUILD_DIR)/ffi.done
fetch-sources: ffi/sources
remove-sources: remove-ffi-sources

# we need to download sources if source path is not specified
ifeq ($(FFI_SOURCES),)
FFI_SOURCES = $(abspath ffi/sources)
$(ANDROID_BUILD_DIR)/ffi: ffi/sources
endif

$(ANDROID_BUILD_DIR)/ffi.done: $(ANDROID_BUILD_DIR)/ffi
	cd $(ANDROID_BUILD_DIR)/ffi && make install -j $(THREADS)
	touch $@

$(ANDROID_BUILD_DIR)/ffi: $(ANDROID_TOOLCHAIN_DIR) | $(ANDROID_BUILD_DIR)
	mkdir -p $@
	cd $@ && $(FFI_SOURCES)/configure $(ANDROID_EXTRA_CONFIGURE_FLAGS)

# managing sources of the default ffi version
FFI_BRANCH_OR_TAG = v3.3-rc0
FFI_REPO = https://github.com/libffi/libffi

ffi/sources:
	git clone $(FFI_REPO) ffi/sources --depth=1 -b $(FFI_BRANCH_OR_TAG)
	cd ffi/sources && autoreconf -i -f

.PHONY: remove-ffi-sources
remove-ffi-sources:
	rm -rf ffi/sources
