# number of threads to use. This value is passed to recursive make calls as -j
# option. To speed up the build invoke make like this: `make THREADS=16`
THREADS ?= 4

BUILD_DIR = build
ANDROID_BUILD_DIR = $(BUILD_DIR)/android
HOST_BUILD_DIR = $(BUILD_DIR)/host
DOWNLOADS_DIR = $(BUILD_DIR)/downloads

OUT_DIR = out
ANDROID_OUT_DIR = $(OUT_DIR)/android
HOST_OUT_DIR = $(OUT_DIR)/host

BASE_NAME = bpftools
RELEASE_VERSION ?= 0.0.1
FULL_NAME = $(BASE_NAME)-$(RELEASE_VERSION)
SYSROOT_NAME = $(FULL_NAME)
ARCHIVE_NAME = $(SYSROOT_NAME).tar.gz

BUILD_TYPE ?= Release

all: $(ARCHIVE_NAME)

include toolchain.mk

# minimal subset of ANDROID_OUT_DIR allowing us to execute bcc, python and
# bpftrace
$(SYSROOT_NAME): scripts python bcc bpftrace $(ANDROID_OUT_DIR)/lib/libc++_shared.so
	mkdir -p $@/bin
	cp $(ANDROID_OUT_DIR)/bin/bpftrace $@/bin/
	cp -P $(ANDROID_OUT_DIR)/bin/python* $@/bin/

	mkdir -p $@/lib
	cp $(ANDROID_OUT_DIR)/lib/libbcc.so $@/lib/

	cp $(ANDROID_OUT_DIR)/lib/libclang.so $@/lib/

	cp $(ANDROID_OUT_DIR)/lib/libc++_shared.so $@/lib/

	cp $(ANDROID_OUT_DIR)/lib/libelf* $@/lib/
	cp $(ANDROID_OUT_DIR)/lib/libfl* $@/lib/

	cp -a $(ANDROID_OUT_DIR)/lib/python3* $@/lib/

	mkdir -p $@/lib64
	cp $(ANDROID_OUT_DIR)/lib64/libffi* $@/lib64/

	mkdir -p $@/share
	cp -a $(ANDROID_OUT_DIR)/share/bcc $@/share/

	cp -r $(ANDROID_OUT_DIR)/*.sh $@/
	cp -r $(ANDROID_OUT_DIR)/bpftrace $@/
	cp -r $(ANDROID_OUT_DIR)/python3 $@/

$(ARCHIVE_NAME): $(SYSROOT_NAME)
	$(TAR) -zcf $@ $(SYSROOT_NAME) --owner=0 --group=0

$(ANDROID_BUILD_DIR) $(HOST_BUILD_DIR) $(DOWNLOADS_DIR):
	mkdir -p $@

$(ANDROID_OUT_DIR) $(HOST_OUT_DIR):
	mkdir -p $@
	mkdir $@/bin
	mkdir $@/include
	mkdir $@/lib

# we need to copy libc++_shared.so, it's part of the toolchain but it's not
# present on your android system
$(ANDROID_OUT_DIR)/lib/libc++_shared.so: $(ANDROID_TOOLCHAIN_DIR) | $(ANDROID_OUT_DIR)
	find $(ANDROID_TOOLCHAIN_DIR) -name libc++_shared.so -exec cp {} $(ANDROID_OUT_DIR)/lib \;

install: $(ARCHIVE_NAME)
	adb push $(ARCHIVE_NAME) /data/local/tmp
	adb shell "cd /data/local/tmp && tar xf $(ARCHIVE_NAME)"
	adb shell "/data/local/tmp/$(SYSROOT_NAME)/setup.sh"
	adb shell "rm /data/local/tmp/$(ARCHIVE_NAME)"
	@echo "Done ! run adb shell and evaluate setup.sh in current shell to set up environment"
	@echo ". /data/local/tmp/$(SYSROOT_NAME)/setup.sh"

uninstall:
	adb shell "rm -rf /data/local/tmp/$(SYSROOT_NAME)"

clean:
	-rm -fr $(BUILD_DIR)
	-rm -fr $(OUT_DIR)
	-rm -fr $(ANDROID_TOOLCHAIN_DIR)
	-rm $(ARCHIVE_NAME)
	-rm -fr $(SYSROOT_NAME)

.PHONY: clean fetch-sources remove-sources install uninstall
.DELETE_ON_ERROR:

include */build.mk
