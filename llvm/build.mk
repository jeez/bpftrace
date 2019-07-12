llvm: $(ANDROID_BUILD_DIR)/llvm.done
fetch-sources: llvm/sources
remove-sources: remove-llvm-sources

# if we're building llvm without explicitely specified LLVM sources path we need
# to check out sources as part of the build process
ifeq ($(LLVM_SOURCES),)
LLVM_SOURCES = $(abspath llvm/sources/llvm)
$(HOST_BUILD_DIR)/llvm: llvm/sources
$(ANDROID_BUILD_DIR)/llvm: llvm/sources
endif

LLVM_EXTRA_CMAKE_FLAGS = -DLLVM_ENABLE_PROJECTS=clang -DCMAKE_BUILD_TYPE=Release
LLVM_EXTRA_HOST_FLAGS = -DLLVM_TEMPORARILY_ALLOW_OLD_TOOLCHAIN=1

# builds and installs llvm and clang libraries for Android. This rule uses
# llvm.done empty file instead of all the installed llvm/clang binaries to keep
# track of whether the rules need to be rerun (for simiplicity)
$(ANDROID_BUILD_DIR)/llvm.done: $(ANDROID_BUILD_DIR)/llvm | $(ANDROID_OUT_DIR)
	cd $(ANDROID_BUILD_DIR)/llvm && $(MAKE) install/strip -j $(THREADS)
	touch $@

# generates llvm build files for Android
$(ANDROID_BUILD_DIR)/llvm: $(HOST_OUT_DIR)/bin/llvm-config
$(ANDROID_BUILD_DIR)/llvm: $(HOST_OUT_DIR)/bin/llvm-tblgen
$(ANDROID_BUILD_DIR)/llvm: $(HOST_OUT_DIR)/bin/clang-tblgen
$(ANDROID_BUILD_DIR)/llvm: $(ANDROID_CMAKE_DEPS)
$(ANDROID_BUILD_DIR)/llvm: | $(ANDROID_BUILD_DIR)
	-mkdir $@
	cd $@ && CXXFLAGS="$(ANDROID_CMAKE_CXXFLAGS)" LDFLAGS="$(ANDROID_CMAKE_LDFLAGS)" \
		$(CMAKE) $(LLVM_SOURCES) \
		$(ANDROID_EXTRA_CMAKE_FLAGS) \
		$(LLVM_EXTRA_CMAKE_FLAGS) \
		-DLLVM_CONFIG_PATH=$(abspath $(HOST_OUT_DIR)/bin/llvm-config) \
		-DLLVM_TABLEGEN=$(abspath $(HOST_OUT_DIR)/bin/llvm-tblgen) \
		-DCLANG_TABLEGEN=$(abspath $(HOST_OUT_DIR)/bin/clang-tblgen) \
		-DLLVM_ENABLE_RTTI=yes

# rules building host llvm-tblgen and clang-tblgen binaries necessary to
# cross compile llvm and clang for Android
$(HOST_OUT_DIR)/bin/llvm-config: $(HOST_BUILD_DIR)/llvm | $(HOST_OUT_DIR)
$(HOST_OUT_DIR)/bin/llvm-tblgen: $(HOST_BUILD_DIR)/llvm | $(HOST_OUT_DIR)
$(HOST_OUT_DIR)/bin/clang-tblgen: $(HOST_BUILD_DIR)/llvm | $(HOST_OUT_DIR)
$(HOST_OUT_DIR)/bin/llvm-config $(HOST_OUT_DIR)/bin/llvm-tblgen $(HOST_OUT_DIR)/bin/clang-tblgen:
	cd $(HOST_BUILD_DIR)/llvm && $(MAKE) -j $(THREADS) $(notdir $@)
	cp $(HOST_BUILD_DIR)/llvm/bin/$(notdir $@) $@

# generates llvm build files for host
$(HOST_BUILD_DIR)/llvm: $(LLVM_SOURCE_DEPS) | $(HOST_BUILD_DIR)
	-mkdir $@
	cd $@ && $(CMAKE) $(LLVM_SOURCES) \
		$(LLVM_EXTRA_CMAKE_FLAGS) \
		$(LLVM_EXTRA_HOST_FLAGS)

# managing sources of the default llvm version
LLVM_BRANCH_OR_TAG = llvmorg-8.0.0
LLVM_REPO = https://github.com/llvm/llvm-project

llvm/sources:
	git clone $(LLVM_REPO) llvm/sources --depth=1 -b $(LLVM_BRANCH_OR_TAG)

.PHONY: remove-llvm-sources
remove-llvm-sources:
	rm -rf llvm/sources
