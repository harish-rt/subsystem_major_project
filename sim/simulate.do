echo "--- Starting UVM Simulation ---"

vsim -sv_seed random +access +rwc +m+top +UVM_VERBOSITY=UVM_DEBUG +UVM_OBJECTION_TRACE \
-L unisims_ver -L unimacro_ver -L secureip \
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
-L xil_defaultlib \
-O0 xil_defaultlib.top core_ip_wraps.glbl \
-l sim_txt.log

add wave -recursive /top/axi4_bram_if/*
add wave -recursive /top/mem_intf/*
add wave -recursive /top/axil_riscv_if/*
add wave -recursive /top/lite_intc_if/*
add wave -recursive /top/dut/IPS_CORE/cdma_introut_0
add wave -recursive /top/intc_if/*
run -all



#add wave -recursive /top/dut/IPS_CORE/axi_interconnect_0_M02_AXI_*
#add wave -recursive /top/dut2/*
#add wave -recursive /top/dut/IPS_CORE/intr*
#add wave -recursive /top/dut/IPS_CORE/*irq
#add wave -recursive /top/dut/IPS_CORE/M02*
#add wave -recursive /top/dut/IPS_CORE/axi_interconnect_0_M02_AXI_*
#add wave -recursive /top/lite_intc_intf/*
#log -r /top/dut/IPS_CORE/axi_intc_0/*
#log -r /top/lite_intc_intf/*
#add wave -r /top/dut/IPS_CORE/axi_intc_0/*
#add wave -r sim:/top/lite_intc_intf/*
#add wave -r sim:/top/dut/*


#log -recursive /top/dut/*
#add wave -recursive /top/dut/*
#add wave -rec sim:/top/lite_intc_intf/*




#vsim -t 1ps +access +r +m+core_ip_wraps -L xpm -L generic_baseblocks_v2_1_0 -L axi_infrastructure_v1_1_0 -L axi_register_slice_v2_1_20 -L fifo_generator_v13_2_5 -L axi_data_fifo_v2_1_19 -L axi_crossbar_v2_1_21 -L core_ip_wraps -L axi_lite_ipif_v3_0_4 -L axi_intc_v4_1_14 -L blk_mem_gen_v8_4_4 -L axi_bram_ctrl_v4_1_2 -L lib_pkg_v1_0_2 -L lib_srl_fifo_v1_0_2 -L lib_fifo_v1_0_14 -L lib_cdc_v1_0_2 -L axi_datamover_v5_1_22 -L axi_sg_v4_1_13 -L axi_cdma_v4_1_20 -L axi_clock_converter_v2_1_19 -L axi_protocol_converter_v2_1_20 -L unisims_ver -L unimacro_ver -L secureip -O5 core_ip_wraps.core_ip_wraps core_ip_wraps.glbl
#run -all

#vsim -advdataflow -sv_seed random +access +rwc +m+top +UVM_VERBOSITY=UVM_DEBUG +UVM_OBJECTION_TRACE \
#vsim -t 1ps +access +r +m+top +UVM_VERBOSITY=UVM_DEBUG +UVM_OBJECTION_TRACE \
#-L xpm \
#-L generic_baseblocks_v2_1_0 \
#-L axi_infrastructure_v1_1_0 \
#-L axi_register_slice_v2_1_20 \
#-L fifo_generator_v13_2_5 \
#-L axi_data_fifo_v2_1_19 \
#-L axi_crossbar_v2_1_21 \
#-L core_ip_wraps \
#-L axi_lite_ipif_v3_0_4 \
#-L axi_intc_v4_1_14 \
#-L blk_mem_gen_v8_4_4 \
#-L axi_bram_ctrl_v4_1_2 \
#-L lib_pkg_v1_0_2 \
#-L lib_srl_fifo_v1_0_2 \
#-L lib_fifo_v1_0_14 \
#-L lib_cdc_v1_0_2 \
#-L axi_datamover_v5_1_22 \
#-L axi_sg_v4_1_13 \
#-L axi_cdma_v4_1_20 \
#-L axi_clock_converter_v2_1_19 \
#-L axi_protocol_converter_v2_1_20 \
#-L unisims_ver \
#-L unimacro_ver \
#-L secureip \
#-L axi_intf \
#-L axi4_lite_mem \
#-L core_perif \
#-L spi_mem \
#-L core_wrapper \
#-L xil_defaultlib \
#-O5 xil_defaultlib.top xil_defaultlib.glbl
#
#add wave -rec -position insertpoint sim:../tb/top/dut/*
#
#run -all
