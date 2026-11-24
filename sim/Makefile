# ==============================================================================
# Makefile - Riviera-PRO (Regression & Coverage Flow with Assert/Toggle Fixes)
# ==============================================================================
SHELL := /bin/bash
.SHELLFLAGS := -o pipefail -c

# 1. Test Suites & Core Variables
SANITY_TESTS = spi_write_data_test mem_wr_rd_test cdma_wr_rd_test core_perif_master_test cpu_base_test soc_master_test reg_read_test perif_reg_read_test timer_reg_access_test cdma_reg_write_read_test intc_reg_write_read_test config_cdma_ral_test gpio_check_test uart_write_data_test

FULL_TESTS   = $(SANITY_TESTS) cdma_sg_test cdma_boundary_check_test intc_sw_irq_test intc_stress_test intc_stress_lite_test bram_multiple_write_read_test bram_address_range_test bram_lower_invalid_addr_test bram_upper_invalid_addr_test load_bram_256_test masters_load_bram_test masters_load_lite_mem_test concurrent_diff_slaves_test gap_pre_system_test interconnect_gaps_test perif_gap_interconnect_test s00_master_outstanding_test s02_masters_load_bram_test s04_master_bram_test s04_master_bram_4kb_test s04_master_outstanding_test s04_master_axi4_mem_test s04_master_out_of_order_test s04_master_interleaving_test s04_master_axi_wrap_test

suite       ?= sanity

ifeq ($(suite), full)
	TEST_LIST = $(FULL_TESTS)
else
	TEST_LIST = $(SANITY_TESTS)
endif

test      ?= soc_master_test
TEST      := $(test)
seed      ?= random
SEED      := $(seed)
verb      ?= UVM_DEBUG
VERBOSITY := $(verb)

gui       ?= 0
waves     ?= 0
cov       ?= 0
toggle    ?= 0
assert    ?= 0
fsm       ?= 0

WORK_LIB   = xil_defaultlib
TOP_MODULE = top

TB_DIR     = ../tb

# 2. Dynamic Output Routing
#TODAY      = $(shell date +%Y-%m-%d)
TODAY 	   := $(shell date +%Y-%m-%d_%H-%M-%S)
REG_DIR    = ./regression_results/$(TODAY)
OUT_DIR   ?= ./logs

LOG_FILE   = $(OUT_DIR)/$(TEST)_seed_$(SEED).log
ACDB_FILE  = $(OUT_DIR)/make_cov_$(TEST).acdb

# 3. Base Flags (Added +dbg and +UVM_OBJECTION_TRACE to match your simulate.do)
VLOG_FLAGS = -sv -dbg -work $(WORK_LIB) -uvmver 1.2 +define+SBD_COMPONENTS -err VCP7803 W1 -err VCP2980 W1 $(LIBS)
VSIM_FLAGS = -sv_seed $(SEED) +access +rwc +dbg +m+top +UVM_TESTNAME=$(TEST) +UVM_VERBOSITY=$(VERBOSITY) +UVM_OBJECTION_TRACE $(RTL_LIBS) -O0 xil_defaultlib.top core_ip_wraps.glbl

# 4. Dynamic Coverage & Assertion Flags
ifeq ($(cov), 1)
	VLOG_FLAGS += -coverage a
	VSIM_FLAGS += -acdb -acdb_cov a -acdb_file $(ACDB_FILE)
endif

ifeq ($(toggle), 1)
	VSIM_FLAGS += -acdb -acdb_cov t -acdb_file $(ACDB_FILE)
endif

ifeq ($(fsm), 1)
	VSIM_FLAGS += -acdb -acdb_cov f -acdb_file $(ACDB_FILE)
endif

ifeq ($(assert), 1)
	VLOG_FLAGS += -coverage a

	VSIM_FLAGS += +TraceAssert
	VSIM_FLAGS += -assert
	VSIM_FLAGS += -acdb -acdb_cov a -acdb_file $(ACDB_FILE)
endif

# LIBS, RTL_LIBS and TB_SRCS definitions
## Pre-compiled Libraries for vlog (-l)
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
                -l axi4_mem \
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
                -L axi4_mem \
                -L core_perif \
                -L spi_mem \
                -L core_wrapper \
                -L xil_defaultlib

TB_SRCS       = $(TB_DIR)/common/soc_addr_pkg.sv \
                $(TB_DIR)/common/axi_parameters.sv \
				$(TB_DIR)/top/axi4_tb_intf.sv \
				$(TB_DIR)/top/axi4_lite_tb_intf.sv \
				$(TB_DIR)/common/assert.sv \
                $(TB_DIR)/mem_agent/mem_pkg.sv \
                $(TB_DIR)/ips_core/axi_intc/intc_package.sv \
                $(TB_DIR)/ips_core/axi_cdma_env/top/axi_cdma_env_pkg.sv \
                $(TB_DIR)/top/cpu_package.sv \
                $(TB_DIR)/core_perif/uart/uart_intf.sv \
                $(TB_DIR)/core_perif/spi/spi_intf.sv \
                $(TB_DIR)/core_perif/gpio/gpio_intf.sv \
                $(TB_DIR)/core_perif/uart/uart_pkg.sv \
                $(TB_DIR)/core_perif/spi/spi_pkg.sv \
                $(TB_DIR)/core_perif/gpio/gpio_pkg.sv \
                $(TB_DIR)/core_perif/core_perif_pkg.sv \
                $(TB_DIR)/top/soc_package.sv \
                $(TB_DIR)/top/tb_top.sv

# 5. Dynamic Tcl Command Construction for -do
# This replaces the hardcoded BATCH_LOG_CMDS so it matches simulate.do exactly
SIM_DO_CMDS = 

ifeq ($(gui), 1)
	SIM_DO_CMDS += log -r /*;
	SIM_DO_CMDS += do waves.tcl;
	#SIM_DO_CMDS += add wave -assert -r /top/slave_if/axi4_aw_payload_stable;
else
	SIM_DO_CMDS += log -rec /top/axi4_bram_if/*; log -rec /top/mem_intf/*; log -rec /top/axil_riscv_if/*; log -rec /top/lite_intc_if/*; log -rec /top/dut/IPS_CORE/cdma_introut_0; log -rec /top/intc_if/*;
endif

ifeq ($(assert), 1)
	SIM_DO_CMDS += assertion fail -log on;
	SIM_DO_CMDS += log -assert -r /top/*;
	SIM_DO_CMDS += log -cover -r /top/*;

	ifeq ($(gui), 1)
		SIM_DO_CMDS += do assert_waves.tcl;
	endif
endif

ifeq ($(toggle), 1)
	SIM_DO_CMDS += toggle -rec -verbose /top/dut/*;
endif

SIM_DO_CMDS += run -all;

ifeq ($(assert), 1)
	SIM_DO_CMDS += assertion report;
endif

# Ensure the database saves at the end of the run
SIM_DO_CMDS += acdb save -o $(ACDB_FILE);

# Prevent the GUI from instantly closing by only exiting in batch mode
ifneq ($(gui), 1)
	SIM_DO_CMDS += exit;
endif

.PHONY: all setup build sim_only gui batch waves regress merge report clean

# 6. Build & Execution Targets
all: setup build run

setup:
	@mkdir -p $(OUT_DIR)

build: setup
	vlog $(VLOG_FLAGS) $(TB_SRCS) 2>&1 | tee $(OUT_DIR)/compile.log

sim_only: gui:=0
sim_only: waves:=0
sim_only: run

gui: gui:=1
gui: build run

batch: gui:=0
batch: waves:=0
batch: build run

waves: gui:=0
waves: waves:=1
waves: build run

run: 
ifeq ($(gui), 1)
	@echo "--- Launching Interactive GUI Simulation ---"
	vsim $(VSIM_FLAGS) -l $(LOG_FILE) -do "$(SIM_DO_CMDS)"
else
ifeq ($(waves), 1)
	@echo "--- Running Batch Simulation with Targeted ASDB Waveforms ---"
	@rm -f dataset.asdb
	vsim -c $(VSIM_FLAGS) -l $(LOG_FILE) -do "$(SIM_DO_CMDS)"
	@if [ -f dataset.asdb ]; then \
		mv dataset.asdb $(OUT_DIR)/$(TEST)_seed_$(SEED).asdb; \
		echo "Waveform ASDB moved to $(OUT_DIR)/$(TEST)_seed_$(SEED).asdb"; \
	fi
else
	@echo "--- Running Fast Batch Simulation ---"
	vsim -c $(VSIM_FLAGS) -l $(LOG_FILE) -do "$(SIM_DO_CMDS)"
endif
endif

# 7. Sequential Regression Flow
regress: build
	@echo "--- Starting Sequential Regression: Suite=$(suite) ---"
	@mkdir -p $(REG_DIR)
	@for t in $(TEST_LIST); do \
		echo "=========================================================="; \
		echo " Running Test: $$t"; \
		echo "=========================================================="; \
		$(MAKE) sim_only test=$$t OUT_DIR=$(REG_DIR) cov=$(cov) toggle=$(toggle) assert=$(assert) fsm=$(fsm) || exit 1; \
	done
	@echo "--- Regression Complete ---"

# 8. Coverage Merging & Reporting
merge:
	@echo "--- Merging Coverage Databases ---"
	vsimsa -do "acdb merge -i $(REG_DIR)/make_cov_*.acdb -o $(REG_DIR)/master_cov.acdb; exit"

report:
	@echo "--- Generating Coverage Reports ---"
	vsimsa -do "acdb report -cov a -txt -i $(ACDB_FILE) -o $(OUT_DIR)/assert_report.txt; \
	            acdb report -cov a -html -i $(ACDB_FILE) -o $(OUT_DIR)/assert_report_html; \
	            acdb report -cov t -html -i $(ACDB_FILE) -o $(OUT_DIR)/toggle_report_html; \
	            exit"
	@echo "Reports generated in $(OUT_DIR)/"

# 9. Regression Reporting
regress_report: merge
	@echo "--- Generating Regression Reports ---"
	vsimsa -do "acdb report -cov a -txt -i $(REG_DIR)/master_cov.acdb -o $(REG_DIR)/assert_report.txt; \
	            acdb report -cov t -html -i $(REG_DIR)/master_cov.acdb -o $(REG_DIR)/toggle_report_html; \
	            exit"
	@echo "Regression reports generated in $(REG_DIR)/"

clean:
	@rm -rf ./logs ./regression_results dataset.asdb dataset.awc compile.log transcript *.log *.asdb *.awc

## ==============================================================================
## Makefile - Riviera-PRO (Aligned with compiletb.do & simulate.do)
## ==============================================================================
#
#TEST          ?= soc_master_test
#VERBOSITY     ?= UVM_DEBUG
#SEED          ?= random
#GUI           ?= 0
#WAVE          ?= 1
#
#WORK_LIB      = xil_defaultlib
#TOP_MODULE    = top
#
#TB_DIR        = ../tb
#LOG_DIR       = ./logs
#LOG_FILE 	  = $(LOG_DIR)/$(TEST)_seed_$(SEED).log
#WAVE_DIR      = ./MakeWaves
#
#VLOG_FLAGS    = -sv -coverage a -dbg \
#				-work $(WORK_LIB) -uvmver 1.2 \
#  				+define+SBD_COMPONENTS \
#                -err VCP7803 W1 -err VCP2980 W1 \
#                $(LIBS)
#
#VSIM_FLAGS    = -sv_seed $(SEED) +access +rwc +m+top \
#                -acdb -acdb_cov ta -acdb_file make_cov.acdb \
#                +UVM_TESTNAME=$(TEST) \
#                +UVM_VERBOSITY=$(VERBOSITY) \
#                $(RTL_LIBS) \
#                -O0 xil_defaultlib.top core_ip_wraps.glbl
#
#GUI_WAVE_CMDS  = toggle -rec /top/*; \
#				 run -all;
#
#BATCH_LOG_CMDS = log -rec /top/axi4_bram_if/*; log -rec /top/mem_intf/*; log -rec /top/axil_riscv_if/*; log -rec /top/lite_intc_if/*; log -rec /top/dut/IPS_CORE/cdma_introut_0; log -rec /top/intc_if/*; run -all;
#
#.PHONY: all setup build run clean run_do view_wave
#
#all: setup build run
#
#setup:
#	@mkdir -p $(LOG_DIR) $(WAVE_DIR)
#
#build: setup
#	vlog $(VLOG_FLAGS) $(TB_SRCS) 2>&1 | tee $(LOG_DIR)/compile.log
#
#run: setup
#ifeq ($(GUI), 1)
#	@echo "--- Launching Interactive GUI Simulation ---"
#	vsim $(VSIM_FLAGS) -l $(LOG_FILE) -do "do waves.tcl; $(GUI_WAVE_CMDS)"
#else
#ifeq ($(WAVE), 1)
#	@echo "--- Running Batch Simulation with Targeted ASDB Waveforms ---"
#	@rm -f dataset.asdb
#	vsim -c $(VSIM_FLAGS) \
#	     -do "$(BATCH_LOG_CMDS)" 2>&1 | tee -a $(LOG_DIR)/$(TEST)_seed_$(SEED).log
#	@if [ -f dataset.asdb ]; then \
#		mv dataset.asdb $(WAVE_DIR)/$(TEST)_seed_$(SEED).asdb; \
#		echo "Waveform ASDB moved to $(WAVE_DIR)/$(TEST)_seed_$(SEED).asdb"; \
#	fi
#else
#	@echo "--- Running Fast Batch Simulation (No Waveforms) ---"
#	vsim -c $(VSIM_FLAGS) \
#	     -do "run -all;" 2>&1 | tee -a $(LOG_DIR)/$(TEST)_seed_$(SEED).log
#endif
#endif
#
#view_wave:
#	riviera -do "wave -create $(WAVE_DIR)/$(TEST)_seed_$(SEED).asdb; wave -rec *;" &
#
#run_do: setup
#	vsim -c -do "do compiletb.do; do simulate.do;" 2>&1 | tee $(LOG_DIR)/sim_do.log
#
#clean:
#	@rm -rf $(LOG_DIR) $(WAVE_DIR) dataset.asdb dataset.awc compile.log transcript *.log *.asdb *.awc
