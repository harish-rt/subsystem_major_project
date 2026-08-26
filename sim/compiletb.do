vlog -work xil_defaultlib -uvmver 1.2 \
-err VCP7803 W1 -err VCP2980 W1 \
-l xpm \
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
-l core_wrapper \
"../mem_agent/mem_pkg.sv" \
"../tb/top/cpu_package.sv" \
"../tb/ips_core/axi_cdma_env/axi_cdma_env_pkg.sv" \
"../tb/top/intc_package.sv" \
"../tb/top/tb_top.sv" 
#2>&1 | tee compiletb.log


#shows in terminal and creates log file
#2>&1 | tee compiletb.log

# won't show in terminal. creates log file only
#> compiletb.log 2>&1


#vlog -work xil_defaultlib -uvmver 1.2 \
#-err VCP7803 W1 -err VCP2980 W1 \
#-l xpm \
#-l generic_baseblocks_v2_1_0 \
#-l axi_infrastructure_v1_1_0 \
#-l axi_register_slice_v2_1_20 \
#-l fifo_generator_v13_2_5 \
#-l axi_data_fifo_v2_1_19 \
#-l axi_crossbar_v2_1_21 \
#-l core_ip_wraps \
#-l axi_lite_ipif_v3_0_4 \
#-l axi_intc_v4_1_14 \
#-l blk_mem_gen_v8_4_4 \
#-l axi_bram_ctrl_v4_1_2 \
#-l lib_pkg_v1_0_2 \
#-l lib_srl_fifo_v1_0_2 \
#-l lib_fifo_v1_0_14 \
#-l lib_cdc_v1_0_2 \
#-l axi_datamover_v5_1_22 \
#-l axi_sg_v4_1_13 \
#-l axi_cdma_v4_1_20 \
#-l axi_clock_converter_v2_1_19 \
#-l axi_protocol_converter_v2_1_20 \
#-l xil_defaultlib \
#-l axi_intf \
#-l axi4_lite_mem \
#-l core_perif \
#-l spi_mem \
#-l core_wrapper \
#"../tb/top/tb_top.sv" 
##2>&1 | tee -a compiletb.log
