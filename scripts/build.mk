scripts: $(ANDROID_OUT_DIR)/bpftrace
scripts: $(ANDROID_OUT_DIR)/python3
scripts: $(ANDROID_OUT_DIR)/run.sh
scripts: $(ANDROID_OUT_DIR)/setup.sh

$(ANDROID_OUT_DIR)/setup.sh: scripts/setup.sh | $(ANDROID_OUT_DIR)
	cp $< $@
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
