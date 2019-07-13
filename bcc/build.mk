bcc: $(ANDROID_BUILD_DIR)/bcc.done
fetch-sources: bcc/sources
remove-sources: remove-bcc-sources

# we need to download sources if source path is not specified
ifeq ($(BCC_SOURCES),)
BCC_SOURCES = $(abspath bcc/sources)
$(ANDROID_BUILD_DIR)/bcc: bcc/sources
endif

# bionic and libbpf (built as part of bcc) both provide linux/compiler.h header.
# In case of bionic the header defines empty __user macro which is used in many
# other headers provided by bionic. Unfortunately libbpf's copy does not define
# that macro and we get many build errors when including not-overriden headers.
# Let's fix it by definiting __user on our own.
BCC_EXTRA_CFLAGS += "-D__user="

# Tests are built as part of regular bcc build and those tests depend on
# symbols that are not provided by bionic.
BCC_EXTRA_CFLAGS += "-include$(abspath bcc/android_fixups/dl_fixups.h)"

# builds and installs bcc for Android.
$(ANDROID_BUILD_DIR)/bcc.done: $(ANDROID_BUILD_DIR)/bcc
ifeq ($(BUILD_TYPE), Debug)
	cd $(ANDROID_BUILD_DIR)/bcc && $(MAKE) install -j $(THREADS)
else
	cd $(ANDROID_BUILD_DIR)/bcc && $(MAKE) install/strip -j $(THREADS)
endif
	touch $@

# generates bcc build files for Android
$(ANDROID_BUILD_DIR)/bcc: llvm flex elfutils
$(ANDROID_BUILD_DIR)/bcc: $(HOST_OUT_DIR)/bin/flex
$(ANDROID_BUILD_DIR)/bcc: $(ANDROID_CMAKE_DEPS)
$(ANDROID_BUILD_DIR)/bcc: | $(ANDROID_BUILD_DIR)
	-mkdir $@
	cd $@ && CXXFLAGS="$(ANDROID_CMAKE_CXXFLAGS) $(BCC_EXTRA_CFLAGS)" \
		CFLAGS="$(BCC_EXTRA_CFLAGS)" LDFLAGS="$(ANDROID_CMAKE_LDFLAGS)" \
		$(CMAKE) $(BCC_SOURCES) \
		$(ANDROID_EXTRA_CMAKE_FLAGS) \
		-DFLEX_EXECUTABLE=$(abspath $(HOST_OUT_DIR)/bin/flex) \
		-DPYTHON_CMD=python3.6

# managing sources of the default python version
BCC_COMMIT_HASH = v0.10.0
BCC_REPO = https://github.com/iovisor/bcc.git

bcc/sources:
	git clone $(BCC_REPO) bcc/sources
	cd bcc/sources && git checkout $(BCC_COMMIT_HASH)

.PHONY: remove-bcc-sources
remove-bcc-sources:
	rm -rf bcc/sources
