catch {file delete -force "sim_txt.log"}

echo "--- Starting UVM Simulation ---"

#vsim -t 1ps -voptargs="+acc" -suppress 12110,3009 -sv_seed random
#vsim -t 1ps -voptargs="+acc" -suppress 12110 -sv_seed random
#vsim -t 1ps -assertdebug -coverage -voptargs="+acc=a" -suppress 12110 -sv_seed random

vsim -t 1ps -voptargs="+acc" -suppress 12110 -sv_seed random \
-sv_lib "D:/Softwares/VLSI/QuestaSimSetup/uvm-1.2/win64/uvm_dpi" \
+UVM_VERBOSITY=UVM_DEBUG \
+UVM_OBJECTION_TRACE \
-L unisim \
-L unisims_ver \
-L unimacro \
-L unimacro_ver \
-L secureip \
-L xpm \
-L generic_baseblocks_v2_1_0 \
-L axi_infrastructure_v1_1_0 \
-L axi_register_slice_v2_1_20 \
-L fifo_generator_v13_2_5 \
-L axi_data_fifo_v2_1_19 \
-L axi_crossbar_v2_1_21 \
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
-L core_ip_wraps \
-L xil_defaultlib \
-L work \
xil_defaultlib.top core_ip_wraps.glbl \
-l sim_txt.log

do wave.do
run -all
#coverage save -assert my_assertions.ucdb
#quit













#add wave -r sim:/top/dut/IPS_CORE/axi_cdma_0/*
#set p /top/dut/IPS_CORE/axi_bram_ctrl_0/U0/gext_inst/abcv4_0_ext_inst/GEN_AXI4/I_FULL_AXI/I_WR_CHNL
#foreach s {
#  bram_addr_ld_en bid_fifo_ld_en bid_fifo_not_empty bid_fifo_rst
#  bid_fifo_ld bid_fifo_rd first_fifo_bid b2b_fifo_bid
#  bid_gets_fifo_load bid_gets_fifo_load_d1
#  bvalid_cnt bvalid_cnt_inc bvalid_cnt_dec bvalid_cnt_non_zero
#  bid_fifo_rd_en axi_bid_int
#} {
#  add wave -radix binary $p/$s
#}
#add wave -r sim:/top/axi4_bram_if/BID
#add wave -r sim:/top/axi4_bram_if/BVALID
#add wave -r sim:/top/axi4_bram_if/BREADY
#add wave -r sim:/top/axi4_bram_if/AWID
#add wave -noupdate -group M03 -radix hexadecimal /top/dut/IPS_CORE/axi_interconnect_0_M03_AXI_*
#add wave -noupdate -group BRAM_CTRL_INT -radix hexadecimal -r -internal /top/dut/IPS_CORE/axi_bram_ctrl_0/*
#add wave -noupdate -group BRAM_RESPONSE -radix hexadecimal \
#/top/dut/IPS_CORE/axi_bram_ctrl_0/s_axi_awid \
#/top/dut/IPS_CORE/axi_bram_ctrl_0/s_axi_awvalid \
#/top/dut/IPS_CORE/axi_bram_ctrl_0/s_axi_awready \
#/top/dut/IPS_CORE/axi_bram_ctrl_0/s_axi_bid \
#/top/dut/IPS_CORE/axi_bram_ctrl_0/s_axi_bvalid \
#/top/dut/IPS_CORE/axi_bram_ctrl_0/s_axi_bready \
#/top/dut/IPS_CORE/axi_bram_ctrl_0/s_axi_bresp
#add wave -recursive /top/mem4_intf/*
#add wave -noupdate -group BRAM_CTRL -radix hex /top/dut/IPS_CORE/axi_bram_ctrl_0/s_axi_*
#add wave -noupdate -group BRAM_CTRL_INT -r -internal /top/dut/IPS_CORE/axi_bram_ctrl_0/*
#add wave -noupdate -group M03 -radix binary /top/dut/IPS_CORE/axi_interconnect_0_M03_AXI_*
#add wave -noupdate -group B_ALL -radix binary /top/dut/IPS_CORE/*BVALID /top/dut/IPS_CORE/*BID
#add wave -recursive /top/dut/IPS_CORE/S04_AXI_0_bvalid
#add wave -recursive /top/dut/IPS_CORE/S04*
#add wave -recursive /top/dut/IPS_CORE/M03*
#add wave -r sim:/top/axi4_bram_if/*
#add wave -r sim:/top/mem_intf/*
#add wave -r sim:/top/axil_riscv_if/*
#add wave -r sim:/top/lite_intc_if/*
#add wave -r sim:/top/dut/IPS_CORE/cdma_introut_0
#add wave -r sim:/top/intc_if/*
#add wave -r sim:/top/cdma_reg_intf/*
#add wave -r sim:/top/cdma_interrupt_intf/*
#add wave -r sim:/top/cdma_data_mov_intf/*
#add wave -r sim:/top/cdma_sg_intf/*



#add wave -recursive /top/axi4_bram_if/*
#add wave -recursive /top/mem_intf/*
#add wave -recursive /top/axil_riscv_if/*
#add wave -recursive /top/lite_intc_if/*
#add wave -recursive /top/dut/IPS_CORE/cdma_introut_0
#add wave -recursive /top/intc_if/*
#add wave -recursive /top/cdma_reg_intf/*
#add wave -recursive /top/cdma_interrupt_intf/*
#add wave -recursive /top/cdma_data_mov_intf/*
#add wave -recursive /top/cdma_sg_intf/*
#add wave -recursive /top/dut/IPS_CORE/*
#echo "--- Starting UVM Simulation ---"
#
#vsim -sv_seed random +access +rwc +m+top +UVM_VERBOSITY=UVM_DEBUG +UVM_OBJECTION_TRACE \
#-L unisims_ver -L unimacro_ver -L secureip \
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
#-L axi_intf \
#-L axi4_lite_mem \
#-L core_perif \
#-L spi_mem \
#-L core_wrapper \
#-L xil_defaultlib \
#-O0 xil_defaultlib.top core_ip_wraps.glbl \
#-l sim_txt.log
#add wave -recursive /top/axi4_bram_if/*
#add wave -recursive /top/mem_intf/*
#add wave -recursive /top/axil_riscv_if/*
#add wave -recursive /top/lite_intc_if/*
#add wave -recursive /top/dut/IPS_CORE/cdma_introut_0
#add wave -recursive /top/dut/IPS_CORE/*
#add wave -recursive /top/intc_if/*
#add wave -recursive /top/cdma_reg_intf/*
#add wave -recursive /top/cdma_interrupt_intf/*
#add wave -recursive /top/cdma_data_mov_intf/*
#add wave -recursive /top/cdma_sg_intf/*
#run -all


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
