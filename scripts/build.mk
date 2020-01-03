scripts: $(ANDROID_OUT_DIR)/bpftrace
scripts: $(ANDROID_OUT_DIR)/python3
scripts: $(ANDROID_OUT_DIR)/run.sh
scripts: $(ANDROID_OUT_DIR)/setup.sh

ifeq ($(NDK_ARCH), arm64)
TARGET_ARCH_ENV_VAR = arm64
else ifeq ($(NDK_ARCH), x86_64)
TARGET_ARCH_ENV_VAR = x86
else
$(error unknown abi $(NDK_ARCH))
endif

$(ANDROID_OUT_DIR)/setup.sh: scripts/setup.sh | $(ANDROID_OUT_DIR)
	@sed -e "s/<TARGET_ARCH_ENV_VAR>/$(TARGET_ARCH_ENV_VAR)/" $< > $@
	chmod +x $@

$(ANDROID_OUT_DIR)/run.sh: scripts/run.sh | $(ANDROID_OUT_DIR)
	cp $< $@
	chmod +x $@

$(ANDROID_OUT_DIR)/bpftrace: scripts/bpftrace | $(ANDROID_OUT_DIR)
	cp $< $@
	chmod +x $@

$(ANDROID_OUT_DIR)/python3: scripts/python3 | $(ANDROID_OUT_DIR)
	cp $< $@
	chmod +x $@
