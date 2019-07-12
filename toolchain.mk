NDK_API = 28
NDK_ARCH = arm64
NDK_PATH = /opt/android_ndk/r17fb1
ANDROID_TRIPLE = aarch64-linux-android

CMAKE = cmake

ANDROID_TOOLCHAIN_DIR = toolchain
ANDROID_CMAKE_TOOLCHAIN_FILE = $(ANDROID_BUILD_DIR)/toolchain-$(NDK_ARCH).cmake
ANDROID_EXTRA_CMAKE_FLAGS = -DCMAKE_TOOLCHAIN_FILE=$(abspath $(ANDROID_CMAKE_TOOLCHAIN_FILE))
ANDROID_EXTRA_CMAKE_FLAGS += -DCMAKE_INSTALL_PREFIX=$(abspath $(ANDROID_OUT_DIR))
ANDROID_EXTRA_CMAKE_FLAGS += -DCMAKE_BUILD_TYPE=Release
ANDROID_CMAKE_DEPS = $(ANDROID_TOOLCHAIN_DIR) $(ANDROID_CMAKE_TOOLCHAIN_FILE)
ANDROID_EXTRA_CONFIGURE_FLAGS = --host=$(ANDROID_TRIPLE) --prefix=$(abspath $(ANDROID_OUT_DIR))

# cmake makes some bad choices when building clang invocations to test target
# platform. It might be necessary (depending on project) to pass additional
# include path to compiler and library lookup paths to linker.
ANDROID_CMAKE_CXXFLAGS = -I $(abspath $(ANDROID_OUT_DIR))/include
ANDROID_CMAKE_LDFLAGS = -L $(abspath $(ANDROID_OUT_DIR))/lib
ANDROID_CMAKE_LDFLAGS += -Wl,-rpath-link -Wl,$(abspath $(ANDROID_OUT_DIR))/lib
ANDROID_CMAKE_LDFLAGS += "-pie"

HOST_UNAME := $(shell uname)
ifeq ($(HOST_UNAME), Darwin)
TAR = gtar
else
TAR = tar
endif

# put standalone toolchain on path so that autotools scripts and makefiles can
# pick it up
export PATH := $(abspath $(ANDROID_TOOLCHAIN_DIR))/bin:$(PATH)

$(ANDROID_TOOLCHAIN_DIR):
	$(NDK_PATH)/build/tools/make_standalone_toolchain.py --arch $(NDK_ARCH) --api $(NDK_API) --install-dir $@

# cmake's CMAKE_TOOLCHAIN_FILE variable allows us to point cmake a file
# setting up numer of variables impacting selection of compiler, linker,
# compiler flags, linker flags and so on. Unfortunately we need to use
# some absolute paths in that file. Instead of computing them in the
# toolchain file we use cd and sed to introduce few macros which resolve
# to the required path. This way we don't need to generate the entire
# file and we don't need to worry with path expansion.
$(ANDROID_CMAKE_TOOLCHAIN_FILE): toolchain-$(NDK_ARCH).cmake
	mkdir -p $(ANDROID_BUILD_DIR)
	cp toolchain-$(NDK_ARCH).cmake $@
	@sed -ibkp -e "s+<TOOLCHAIN_PATH>+$(abspath $(ANDROID_TOOLCHAIN_DIR))+" $@
	@sed -ibkp -e "s+<FIND_ROOT_PATH>+$(abspath $(ANDROID_OUT_DIR))+" $@
