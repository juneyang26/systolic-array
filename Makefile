# ---------------------------------------------------
# For Cadence Tools (Xcelium & SimVision)
# ---------------------------------------------------


# ---------------- include below --------------------
#
#        $shm_open("waves.shm");
#        $shm_probe("ACM");
#
# ---------------------------------------------------

CURRENT_DIR := $(shell pwd)
WORKSPACE	:= $(CURRENT_DIR)/WORKSPACE
RTL_FILES = ../rtl/pe.sv \
			../rtl/result_buffer.sv \
			../rtl/systolic_array.sv \
			../rtl/systolic_controller.sv \
			../rtl/top_systolic.sv

TB_FILES = ../tb/top_systolic_tb.sv

.PHONY: help

help:
	@echo "-------------------------------------------"
	@echo "  make xrun      - Build and simulate inside WORKSPACE"
	@echo "  make simvision - View waveforms from WORKSPACE"
	@echo "  make clean     - Delete WORKSPACE"
	@echo "-------------------------------------------"

.PHONY: clean
clean:
	@rm -rf $(WORKSPACE)

.PHONY: xrun simvision
XRUN_FLAGS = -64bit \
             -sv \
             -linedebug \
             -access +rwc \
             -timescale 1ns/1ps \
             -licqueue
	
xrun:
	@mkdir -p $(WORKSPACE)
	cd $(WORKSPACE) && \
	xrun $(XRUN_FLAGS) $(RTL_FILES) $(TB_FILES)

simvision:
	cd $(WORKSPACE) && simvision waves.shm &