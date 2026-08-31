# ==============================================================================
# Makefile - Riviera-PRO (Aligned with compiletb.do & simulate.do)
# ==============================================================================

TEST          ?= read_cdma_test
VERBOSITY     ?= UVM_LOW
SEED          ?= random
GUI           ?= 0
WAVE          ?= 1

WORK_LIB      = xil_defaultlib
TOP_MODULE    = top

TB_DIR        = ../tb
LOG_DIR       = ./logs
WAVE_DIR      = ./waves

# Pre-compiled Libraries for vlog (-l)
LIBS          = -l xpm \
                -l generic_baseblocks_v2_1_0 \
                -l axi_infrastructure_v1_1_0 \
                -l axi_register_slice_v2_1_20 \
                -l fifo_generator_v13_2_5 \
                -l axi_data_fifo_v2_1_19 \
                -l axi_crossbar_v2_1_21 \
                -l core_ip_wraps \
                -l axi_lite_ipif_v3_0_4 \
                -l axi_intc_v4_1_14 \
                -l blk_mem_gen_v8_4_4 \
                -l axi_bram_ctrl_v4_1_2 \
                -l lib_pkg_v1_0_2 \
                -l lib_srl_fifo_v1_0_2 \
                -l lib_fifo_v1_0_14 \
                -l lib_cdc_v1_0_2 \
                -l axi_datamover_v5_1_22 \
                -l axi_sg_v4_1_13 \
                -l axi_cdma_v4_1_20 \
                -l axi_clock_converter_v2_1_19 \
                -l axi_protocol_converter_v2_1_20 \
                -l xil_defaultlib \
                -l axi_intf \
                -l axi4_lite_mem \
                -l core_perif \
                -l spi_mem \
                -l core_wrapper

# Pre-compiled Libraries for vsim (-L)
RTL_LIBS      = -L unisims_ver -L unimacro_ver -L secureip \
                -L xpm \
                -L generic_baseblocks_v2_1_0 \
                -L axi_infrastructure_v1_1_0 \
                -L axi_register_slice_v2_1_20 \
                -L fifo_generator_v13_2_5 \
                -L axi_data_fifo_v2_1_19 \
                -L axi_crossbar_v2_1_21 \
                -L core_ip_wraps \
                -L axi_lite_ipif_v3_0_4 \
                -L axi_intc_v4_1_14 \
                -L blk_mem_gen_v8_4_4 \
                -L axi_bram_ctrl_v4_1_2 \
                -L lib_pkg_v1_0_2 \
                -L lib_srl_fifo_v1_0_2 \
                -L lib_fifo_v1_0_14 \
                -L lib_cdc_v1_0_2 \
                -L axi_datamover_v5_1_22 \
                -L axi_sg_v4_1_13 \
                -L axi_cdma_v4_1_20 \
                -L axi_clock_converter_v2_1_19 \
                -L axi_protocol_converter_v2_1_20 \
                -L axi_intf \
                -L axi4_lite_mem \
                -L core_perif \
                -L spi_mem \
                -L core_wrapper \
                -L xil_defaultlib

TB_SRCS       = $(TB_DIR)/common/soc_addr_pkg.sv \
                $(TB_DIR)/common/config_tb.sv \
                $(TB_DIR)/common/axi_parameters.sv \
                $(TB_DIR)/top/cpu_package.sv \
                $(TB_DIR)/ips_core/axi_cdma_env/top/axi_cdma_env_pkg.sv \
                $(TB_DIR)/mem_agent/mem_pkg.sv \
                $(TB_DIR)/ips_core/axi_intc/intc_package.sv \
                $(TB_DIR)/top/soc_package.sv \
                $(TB_DIR)/top/tb_top.sv

VLOG_FLAGS    = -work $(WORK_LIB) -uvmver 1.2 \
                -err VCP7803 W1 -err VCP2980 W1 \
                $(LIBS)

VSIM_FLAGS    = -sv_seed $(SEED) +access +rwc +m+top \
                +UVM_TESTNAME=$(TEST) \
                +UVM_VERBOSITY=$(VERBOSITY) \
                $(RTL_LIBS) \
                -O0 xil_defaultlib.top core_ip_wraps.glbl

GUI_WAVE_CMDS  = wave -rec /top/axi4_bram_if/*; wave -rec /top/mem_intf/*; wave -rec /top/axil_riscv_if/*; wave -rec /top/lite_intc_if/*; wave -rec /top/dut/IPS_CORE/cdma_introut_0; wave -rec /top/intc_if/*; run -all;
BATCH_LOG_CMDS = log -rec /top/axi4_bram_if/*; log -rec /top/mem_intf/*; log -rec /top/axil_riscv_if/*; log -rec /top/lite_intc_if/*; log -rec /top/dut/IPS_CORE/cdma_introut_0; log -rec /top/intc_if/*; run -all;

.PHONY: all setup build run clean run_do view_wave

all: setup build run

setup:
	@mkdir -p $(LOG_DIR) $(WAVE_DIR)

build: setup
	vlog $(VLOG_FLAGS) $(TB_SRCS) 2>&1 | tee $(LOG_DIR)/compile.log

run: setup
ifeq ($(GUI), 1)
	@echo "--- Launching Interactive GUI Simulation ---"
	vsim $(VSIM_FLAGS) -do "$(GUI_WAVE_CMDS)"
else
ifeq ($(WAVE), 1)
	@echo "--- Running Batch Simulation with Targeted ASDB Waveforms ---"
	@rm -f dataset.asdb
	vsim -c $(VSIM_FLAGS) \
	     -do "$(BATCH_LOG_CMDS)" 2>&1 | tee -a $(LOG_DIR)/$(TEST)_seed_$(SEED).log
	@if [ -f dataset.asdb ]; then \
		mv dataset.asdb $(WAVE_DIR)/$(TEST)_seed_$(SEED).asdb; \
		echo "Waveform ASDB moved to $(WAVE_DIR)/$(TEST)_seed_$(SEED).asdb"; \
	fi
else
	@echo "--- Running Fast Batch Simulation (No Waveforms) ---"
	vsim -c $(VSIM_FLAGS) \
	     -do "run -all;" 2>&1 | tee -a $(LOG_DIR)/$(TEST)_seed_$(SEED).log
endif
endif

view_wave:
	riviera -do "wave -create $(WAVE_DIR)/$(TEST)_seed_$(SEED).asdb; wave -rec *;" &

run_do: setup
	vsim -c -do "do compiletb.do; do simulate.do;" 2>&1 | tee $(LOG_DIR)/sim_do.log

clean:
	@rm -rf $(LOG_DIR) $(WAVE_DIR) dataset.asdb dataset.awc compile.log transcript *.log *.asdb *.awc

## Single-line macro commands to prevent shell pipe breakages
#GUI_WAVE_CMDS  = wave -rec /top/axi4_bram_if/*; wave -rec /top/mem_intf/*; wave -rec /top/axil_riscv_if/*; wave -rec /top/lite_intc_if/*; wave -rec /top/dut/IPS_CORE/cdma_introut_0; wave -rec /top/intc_if/*; run -all;
##BATCH_LOG_CMDS = log -rec /top/axi4_bram_if/*; log -rec /top/mem_intf/*; log -rec /top/axil_riscv_if/*; log -rec /top/lite_intc_if/*; log -rec /top/dut/IPS_CORE/cdma_introut_0; log -rec /top/intc_if/*; run -all; quit -f;
#
#.PHONY: all setup build run clean run_do
#
#all: setup build run
#
#setup:
#	@mkdir -p $(LOG_DIR) $(WAVE_DIR)
#
#build: setup
#	vlog $(VLOG_FLAGS) $(TB_SRCS) 2>&1 | tee $(LOG_DIR)/compile.log
#
## Logging signals only (no dataset/awc commands needed)
#BATCH_LOG_CMDS = log -rec /top/axi4_bram_if/*; \
#                 log -rec /top/mem_intf/*; \
#                 log -rec /top/axil_riscv_if/*; \
#                 log -rec /top/lite_intc_if/*; \
#                 log -rec /top/dut/IPS_CORE/cdma_introut_0; \
#                 log -rec /top/intc_if/*; \
#                 run -all;
#
## ------------------------------------------------------------------------------
## Run Target
## ------------------------------------------------------------------------------
#run: setup
#ifeq ($(GUI), 1)
#	@echo "--- Launching Interactive GUI Simulation ---"
#	vsim $(VSIM_FLAGS) -do "$(GUI_WAVE_CMDS)"
#else
#ifeq ($(WAVE), 1)
#	@echo "--- Running Batch Simulation with Targeted ASDB Waveforms ---"
#	@rm -f dataset.awc
#	vsim -c $(VSIM_FLAGS) \
#	     -l $(LOG_DIR)/$(TEST)_seed_$(SEED).log \
#	     -do "$(BATCH_LOG_CMDS)" 2>&1 | tee -a $(LOG_DIR)/$(TEST)_seed_$(SEED).log
#	@if [ -f dataset.awc ]; then \
#		mv dataset.awc $(WAVE_DIR)/$(TEST)_seed_$(SEED).awc; \
#		echo "Waveform saved to $(WAVE_DIR)/$(TEST)_seed_$(SEED).awc"; \
#	fi
#else
#	@echo "--- Running Fast Batch Simulation (No Waveforms) ---"
#	vsim -c $(VSIM_FLAGS) \
#	     -l $(LOG_DIR)/$(TEST)_seed_$(SEED).log \
#	     -do "run -all;" 2>&1 | tee -a $(LOG_DIR)/$(TEST)_seed_$(SEED).log
#endif
#endif
#
#run_do: setup
#	vsim -c -do "do compiletb.do; do simulate.do;" 2>&1 | tee $(LOG_DIR)/sim_do.log
#
#clean:
#	@rm -rf $(LOG_DIR) $(WAVE_DIR) dataset.awc compile.log transcript *.log *.awc
