bpftrace: $(ANDROID_OUT_DIR)/bin/bpftrace
fetch-sources: bpftrace/sources
remove-sources: remove-bpftrace-sources

# we need to download sources if source path is not specified
ifeq ($(BPFTRACE_SOURCES),)
BPFTRACE_SOURCES = $(abspath bpftrace/sources)
$(ANDROID_BUILD_DIR)/bpftrace: bpftrace/sources
endif

# builds and installs bpftrace for Android.
$(ANDROID_OUT_DIR)/bin/bpftrace: $(ANDROID_BUILD_DIR)/bpftrace | $(ANDROID_OUT_DIR)
	cd $(ANDROID_BUILD_DIR)/bpftrace && $(MAKE) bpftrace -j $(THREADS)
	cp $(ANDROID_BUILD_DIR)/bpftrace/src/bpftrace $@

# generates bcc build files for Android
$(ANDROID_BUILD_DIR)/bpftrace: bcc elfutils flex llvm
$(ANDROID_BUILD_DIR)/bpftrace: $(ANDROID_OUT_DIR)/lib/libc++_shared.so
$(ANDROID_BUILD_DIR)/bpftrace: $(HOST_OUT_DIR)/bin/flex
$(ANDROID_BUILD_DIR)/bpftrace: $(ANDROID_CMAKE_DEPS)
$(ANDROID_BUILD_DIR)/bpftrace: | $(ANDROID_BUILD_DIR)
	-mkdir $@
	cd $@ && CXXFLAGS="$(ANDROID_CMAKE_CXXFLAGS)" LDFLAGS="$(ANDROID_CMAKE_LDFLAGS)" \
		$(CMAKE) $(BPFTRACE_SOURCES) \
		$(ANDROID_EXTRA_CMAKE_FLAGS) \
		-DLIBBCC_INCLUDE_DIRS=$(abspath $(ANDROID_OUT_DIR)/include/bcc) \
		-DFLEX_EXECUTABLE=$(abspath $(HOST_OUT_DIR)/bin/flex)

# managing sources of the default python version
BPFTRACE_COMMIT_HASH = v0.9.1
BPFTRACE_REPO = https://github.com/iovisor/bpftrace.git/

bpftrace/sources:
	git clone $(BPFTRACE_REPO) bpftrace/sources
	cd bpftrace/sources && git checkout $(BPFTRACE_COMMIT_HASH)

.PHONY: remove-bpftrace-sources
remove-bpftrace-sources:
	rm -rf bpftrace/sources
