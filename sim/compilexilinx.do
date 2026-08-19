vlib work
vlib riviera
vlib riviera/xpm
vlib riviera/generic_baseblocks_v2_1_0
vlib riviera/axi_infrastructure_v1_1_0
vlib riviera/axi_register_slice_v2_1_20
vlib riviera/fifo_generator_v13_2_5
vlib riviera/axi_data_fifo_v2_1_19
vlib riviera/axi_crossbar_v2_1_21
vlib riviera/core_ip_wraps
vlib riviera/axi_lite_ipif_v3_0_4
vlib riviera/axi_intc_v4_1_14
vlib riviera/blk_mem_gen_v8_4_4
vlib riviera/axi_bram_ctrl_v4_1_2
vlib riviera/lib_pkg_v1_0_2
vlib riviera/lib_srl_fifo_v1_0_2
vlib riviera/lib_fifo_v1_0_14
vlib riviera/lib_cdc_v1_0_2
vlib riviera/axi_datamover_v5_1_22
vlib riviera/axi_sg_v4_1_13
vlib riviera/axi_cdma_v4_1_20
vlib riviera/axi_clock_converter_v2_1_19
vlib riviera/axi_protocol_converter_v2_1_20
vlib riviera/xil_defaultlib

vmap xpm riviera/xpm
vmap generic_baseblocks_v2_1_0 riviera/generic_baseblocks_v2_1_0
vmap axi_infrastructure_v1_1_0 riviera/axi_infrastructure_v1_1_0
vmap axi_register_slice_v2_1_20 riviera/axi_register_slice_v2_1_20
vmap fifo_generator_v13_2_5 riviera/fifo_generator_v13_2_5
vmap axi_data_fifo_v2_1_19 riviera/axi_data_fifo_v2_1_19
vmap axi_crossbar_v2_1_21 riviera/axi_crossbar_v2_1_21
vmap core_ip_wraps riviera/core_ip_wraps
vmap axi_lite_ipif_v3_0_4 riviera/axi_lite_ipif_v3_0_4
vmap axi_intc_v4_1_14 riviera/axi_intc_v4_1_14
vmap blk_mem_gen_v8_4_4 riviera/blk_mem_gen_v8_4_4
vmap axi_bram_ctrl_v4_1_2 riviera/axi_bram_ctrl_v4_1_2
vmap lib_pkg_v1_0_2 riviera/lib_pkg_v1_0_2
vmap lib_srl_fifo_v1_0_2 riviera/lib_srl_fifo_v1_0_2
vmap lib_fifo_v1_0_14 riviera/lib_fifo_v1_0_14
vmap lib_cdc_v1_0_2 riviera/lib_cdc_v1_0_2
vmap axi_datamover_v5_1_22 riviera/axi_datamover_v5_1_22
vmap axi_sg_v4_1_13 riviera/axi_sg_v4_1_13
vmap axi_cdma_v4_1_20 riviera/axi_cdma_v4_1_20
vmap axi_clock_converter_v2_1_19 riviera/axi_clock_converter_v2_1_19
vmap axi_protocol_converter_v2_1_20 riviera/axi_protocol_converter_v2_1_20
vmap xil_defaultlib riviera/xil_defaultlib

vlog -work xpm -sv2k12 "+incdir+/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/ec67/hdl" \
"/opt/xilinx/2025.1/Vivado/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"/opt/xilinx/2025.1/Vivado/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"/opt/xilinx/2025.1/Vivado/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv"

vcom -work xpm -93 \
"/opt/xilinx/2025.1/Vivado/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work generic_baseblocks_v2_1_0  -v2k5 "+incdir+/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/ec67/hdl" \
"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/b752/hdl/generic_baseblocks_v2_1_vl_rfs.v" \

vlog -work axi_infrastructure_v1_1_0  -v2k5 "+incdir+/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/ec67/hdl" \
"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \

vlog -work axi_register_slice_v2_1_20  -v2k5 "+incdir+/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/ec67/hdl" \
"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/72d4/hdl/axi_register_slice_v2_1_vl_rfs.v" \

vlog -work fifo_generator_v13_2_5  -v2k5 "+incdir+/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/ec67/hdl" \
"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/276e/simulation/fifo_generator_vlog_beh.v" \

vcom -work fifo_generator_v13_2_5 -93 \
"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/276e/hdl/fifo_generator_v13_2_rfs.vhd" \

vlog -work fifo_generator_v13_2_5  -v2k5 "+incdir+/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/ec67/hdl" \
"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/276e/hdl/fifo_generator_v13_2_rfs.v" \

vlog -work axi_data_fifo_v2_1_19  -v2k5 "+incdir+/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/ec67/hdl" \
"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/60de/hdl/axi_data_fifo_v2_1_vl_rfs.v" \

vlog -work axi_crossbar_v2_1_21  -v2k5 "+incdir+/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/ec67/hdl" \
"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/6b0d/hdl/axi_crossbar_v2_1_vl_rfs.v" \

vlog -work core_ip_wraps  -v2k5 "+incdir+/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/ec67/hdl" \
"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ip/core_ip_wraps_xbar_0/sim/core_ip_wraps_xbar_0.v" \

vcom -work axi_lite_ipif_v3_0_4 -93 \
"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/66ea/hdl/axi_lite_ipif_v3_0_vh_rfs.vhd" \

vcom -work axi_intc_v4_1_14 -93 \
"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/f78a/hdl/axi_intc_v4_1_vh_rfs.vhd" \

vcom -work core_ip_wraps -93 \
"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ip/core_ip_wraps_axi_intc_0_0/sim/core_ip_wraps_axi_intc_0_0.vhd" \

vlog -work core_ip_wraps  -v2k5 "+incdir+/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/ec67/hdl" \
"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/sim/core_ip_wraps.v" \

vlog -work blk_mem_gen_v8_4_4  -v2k5 "+incdir+/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/ec67/hdl" \
"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/2985/simulation/blk_mem_gen_v8_4.v" \

vlog -work core_ip_wraps  -v2k5 "+incdir+/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/ec67/hdl" \
"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ip/core_ip_wraps_blk_mem_gen_0_0/sim/core_ip_wraps_blk_mem_gen_0_0.v" \

vcom -work axi_bram_ctrl_v4_1_2 -93 \
"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/a002/hdl/axi_bram_ctrl_v4_1_rfs.vhd" \

vcom -work core_ip_wraps -93 \
"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ip/core_ip_wraps_axi_bram_ctrl_0_1/sim/core_ip_wraps_axi_bram_ctrl_0_1.vhd" \

vcom -work lib_pkg_v1_0_2 -93 \
"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/0513/hdl/lib_pkg_v1_0_rfs.vhd" \

vcom -work lib_srl_fifo_v1_0_2 -93 \
"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/51ce/hdl/lib_srl_fifo_v1_0_rfs.vhd" \

vcom -work lib_fifo_v1_0_14 -93 \
"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/a5cb/hdl/lib_fifo_v1_0_rfs.vhd" \

vcom -work lib_cdc_v1_0_2 -93 \
"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/ef1e/hdl/lib_cdc_v1_0_rfs.vhd" \

vcom -work axi_datamover_v5_1_22 -93 \
"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/1e40/hdl/axi_datamover_v5_1_vh_rfs.vhd" \

vcom -work axi_sg_v4_1_13 -93 \
"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/4919/hdl/axi_sg_v4_1_rfs.vhd" \

vcom -work axi_cdma_v4_1_20 -93 \
"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/02b1/hdl/axi_cdma_v4_1_vh_rfs.vhd" \

vcom -work core_ip_wraps -93 \
"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ip/core_ip_wraps_axi_cdma_0_0/sim/core_ip_wraps_axi_cdma_0_0.vhd" \

vlog -work axi_clock_converter_v2_1_19  -v2k5 "+incdir+/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/ec67/hdl" \
"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/9e81/hdl/axi_clock_converter_v2_1_vl_rfs.v" \

vlog -work core_ip_wraps  -v2k5 "+incdir+/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/ec67/hdl" \
"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ip/core_ip_wraps_auto_cc_6/sim/core_ip_wraps_auto_cc_6.v" \

vlog -work axi_protocol_converter_v2_1_20  -v2k5 "+incdir+/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/ec67/hdl" \
"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/c4a6/hdl/axi_protocol_converter_v2_1_vl_rfs.v" \

vlog -work core_ip_wraps  -v2k5 "+incdir+/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/ec67/hdl" \
"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ip/core_ip_wraps_auto_pc_4/sim/core_ip_wraps_auto_pc_4.v" \
"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ip/core_ip_wraps_auto_cc_7/sim/core_ip_wraps_auto_cc_7.v" \
"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ip/core_ip_wraps_auto_cc_8/sim/core_ip_wraps_auto_cc_8.v" \
"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ip/core_ip_wraps_auto_pc_5/sim/core_ip_wraps_auto_pc_5.v" \
"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ip/core_ip_wraps_auto_cc_9/sim/core_ip_wraps_auto_cc_9.v" \
"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ip/core_ip_wraps_auto_cc_10/sim/core_ip_wraps_auto_cc_10.v" \
"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ip/core_ip_wraps_auto_cc_0/sim/core_ip_wraps_auto_cc_0.v" \
"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ip/core_ip_wraps_auto_pc_0/sim/core_ip_wraps_auto_pc_0.v" \
"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ip/core_ip_wraps_auto_cc_1/sim/core_ip_wraps_auto_cc_1.v" \
"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ip/core_ip_wraps_auto_pc_1/sim/core_ip_wraps_auto_pc_1.v" \
"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ip/core_ip_wraps_auto_cc_2/sim/core_ip_wraps_auto_cc_2.v" \
"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ip/core_ip_wraps_auto_pc_2/sim/core_ip_wraps_auto_pc_2.v" \
"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ip/core_ip_wraps_auto_cc_3/sim/core_ip_wraps_auto_cc_3.v" \
"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ip/core_ip_wraps_auto_cc_4/sim/core_ip_wraps_auto_cc_4.v" \
"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ip/core_ip_wraps_auto_pc_3/sim/core_ip_wraps_auto_pc_3.v" \
"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ip/core_ip_wraps_auto_cc_5/sim/core_ip_wraps_auto_cc_5.v"

vlog -work core_ip_wraps "glbl.v" 








#vlib work
#vlib riviera
#
#vlib riviera/xpm
#vlib riviera/generic_baseblocks_v2_1_0
#vlib riviera/axi_infrastructure_v1_1_0
#vlib riviera/axi_register_slice_v2_1_20
#vlib riviera/fifo_generator_v13_2_5
#vlib riviera/axi_data_fifo_v2_1_19
#vlib riviera/axi_crossbar_v2_1_21
#vlib riviera/core_ip_wraps
#vlib riviera/axi_lite_ipif_v3_0_4
#vlib riviera/axi_intc_v4_1_14
#vlib riviera/blk_mem_gen_v8_4_4
#vlib riviera/axi_bram_ctrl_v4_1_2
#vlib riviera/lib_pkg_v1_0_2
#vlib riviera/lib_srl_fifo_v1_0_2
#vlib riviera/lib_fifo_v1_0_14
#vlib riviera/lib_cdc_v1_0_2
#vlib riviera/axi_datamover_v5_1_22
#vlib riviera/axi_sg_v4_1_13
#vlib riviera/axi_cdma_v4_1_20
#vlib riviera/axi_clock_converter_v2_1_19
#vlib riviera/axi_protocol_converter_v2_1_20
#vlib riviera/xil_defaultlib
#
#vmap xpm riviera/xpm
#vmap generic_baseblocks_v2_1_0 riviera/generic_baseblocks_v2_1_0
#vmap axi_infrastructure_v1_1_0 riviera/axi_infrastructure_v1_1_0
#vmap axi_register_slice_v2_1_20 riviera/axi_register_slice_v2_1_20
#vmap fifo_generator_v13_2_5 riviera/fifo_generator_v13_2_5
#vmap axi_data_fifo_v2_1_19 riviera/axi_data_fifo_v2_1_19
#vmap axi_crossbar_v2_1_21 riviera/axi_crossbar_v2_1_21
#vmap core_ip_wraps riviera/core_ip_wraps
#vmap axi_lite_ipif_v3_0_4 riviera/axi_lite_ipif_v3_0_4
#vmap axi_intc_v4_1_14 riviera/axi_intc_v4_1_14
#vmap blk_mem_gen_v8_4_4 riviera/blk_mem_gen_v8_4_4
#vmap axi_bram_ctrl_v4_1_2 riviera/axi_bram_ctrl_v4_1_2
#vmap lib_pkg_v1_0_2 riviera/lib_pkg_v1_0_2
#vmap lib_srl_fifo_v1_0_2 riviera/lib_srl_fifo_v1_0_2
#vmap lib_fifo_v1_0_14 riviera/lib_fifo_v1_0_14
#vmap lib_cdc_v1_0_2 riviera/lib_cdc_v1_0_2
#vmap axi_datamover_v5_1_22 riviera/axi_datamover_v5_1_22
#vmap axi_sg_v4_1_13 riviera/axi_sg_v4_1_13
#vmap axi_cdma_v4_1_20 riviera/axi_cdma_v4_1_20
#vmap axi_clock_converter_v2_1_19 riviera/axi_clock_converter_v2_1_19
#vmap axi_protocol_converter_v2_1_20 riviera/axi_protocol_converter_v2_1_20
#vmap xil_defaultlib riviera/xil_defaultlib
#
#vlog -work xpm  -sv2k12 "+incdir+/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/ec67/hdl" \
#"/opt/xilinx/2025.1/Vivado/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
#"/opt/xilinx/2025.1/Vivado/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
#"/opt/xilinx/2025.1/Vivado/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
#
#vcom -work xpm -93 \
#"/opt/xilinx/2025.1/Vivado/data/ip/xpm/xpm_VCOMP.vhd" \
#
#vlog -work generic_baseblocks_v2_1_0  -v2k5 "+incdir+/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/ec67/hdl" \
#"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/b752/hdl/generic_baseblocks_v2_1_vl_rfs.v" \
#
#vlog -work axi_infrastructure_v1_1_0  -v2k5 "+incdir+/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/ec67/hdl" \
#"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \
#
#vlog -work axi_register_slice_v2_1_20  -v2k5 "+incdir+/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/ec67/hdl" \
#"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/72d4/hdl/axi_register_slice_v2_1_vl_rfs.v" \
#
#vlog -work fifo_generator_v13_2_5  -v2k5 "+incdir+/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/ec67/hdl" \
#"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/276e/simulation/fifo_generator_vlog_beh.v" \
#
#vcom -work fifo_generator_v13_2_5 -93 \
#"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/276e/hdl/fifo_generator_v13_2_rfs.vhd" \
#
#vlog -work fifo_generator_v13_2_5  -v2k5 "+incdir+/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/ec67/hdl" \
#"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/276e/hdl/fifo_generator_v13_2_rfs.v" \
#
#vlog -work axi_data_fifo_v2_1_19  -v2k5 "+incdir+/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/ec67/hdl" \
#"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/60de/hdl/axi_data_fifo_v2_1_vl_rfs.v" \
#
#vlog -work axi_crossbar_v2_1_21  -v2k5 "+incdir+/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/ec67/hdl" \
#"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/6b0d/hdl/axi_crossbar_v2_1_vl_rfs.v" \
#
#vlog -work core_ip_wraps  -v2k5 "+incdir+/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/ec67/hdl" \
#"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ip/core_ip_wraps_xbar_0/sim/core_ip_wraps_xbar_0.v" \
#
#vcom -work axi_lite_ipif_v3_0_4 -93 \
#"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/66ea/hdl/axi_lite_ipif_v3_0_vh_rfs.vhd" \
#
#vcom -work axi_intc_v4_1_14 -93 \
#"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/f78a/hdl/axi_intc_v4_1_vh_rfs.vhd" \
#
#vcom -work core_ip_wraps -93 \
#"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ip/core_ip_wraps_axi_intc_0_0/sim/core_ip_wraps_axi_intc_0_0.vhd" \
#
#vlog -work core_ip_wraps  -v2k5 "+incdir+/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/ec67/hdl" \
#"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/sim/core_ip_wraps.v" \
#
#vlog -work blk_mem_gen_v8_4_4  -v2k5 "+incdir+/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/ec67/hdl" \
#"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/2985/simulation/blk_mem_gen_v8_4.v" \
#
#vlog -work core_ip_wraps  -v2k5 "+incdir+/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/ec67/hdl" \
#"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ip/core_ip_wraps_blk_mem_gen_0_0/sim/core_ip_wraps_blk_mem_gen_0_0.v" \
#
#vcom -work axi_bram_ctrl_v4_1_2 -93 \
#"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/a002/hdl/axi_bram_ctrl_v4_1_rfs.vhd" \
#
#vcom -work core_ip_wraps -93 \
#"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ip/core_ip_wraps_axi_bram_ctrl_0_1/sim/core_ip_wraps_axi_bram_ctrl_0_1.vhd" \
#
#vcom -work lib_pkg_v1_0_2 -93 \
#"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/0513/hdl/lib_pkg_v1_0_rfs.vhd" \
#
#vcom -work lib_srl_fifo_v1_0_2 -93 \
#"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/51ce/hdl/lib_srl_fifo_v1_0_rfs.vhd" \
#
#vcom -work lib_fifo_v1_0_14 -93 \
#"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/a5cb/hdl/lib_fifo_v1_0_rfs.vhd" \
#
#vcom -work lib_cdc_v1_0_2 -93 \
#"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/ef1e/hdl/lib_cdc_v1_0_rfs.vhd" \
#
#vcom -work axi_datamover_v5_1_22 -93 \
#"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/1e40/hdl/axi_datamover_v5_1_vh_rfs.vhd" \
#
#vcom -work axi_sg_v4_1_13 -93 \
#"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/4919/hdl/axi_sg_v4_1_rfs.vhd" \
#
#vcom -work axi_cdma_v4_1_20 -93 \
#"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/02b1/hdl/axi_cdma_v4_1_vh_rfs.vhd" \
#
#vcom -work core_ip_wraps -93 \
#"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ip/core_ip_wraps_axi_cdma_0_0/sim/core_ip_wraps_axi_cdma_0_0.vhd" \
#
#vlog -work axi_clock_converter_v2_1_19  -v2k5 "+incdir+/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/ec67/hdl" \
#"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/9e81/hdl/axi_clock_converter_v2_1_vl_rfs.v" \
#
#vlog -work core_ip_wraps  -v2k5 "+incdir+/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/ec67/hdl" \
#"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ip/core_ip_wraps_auto_cc_6/sim/core_ip_wraps_auto_cc_6.v" \
#
#vlog -work axi_protocol_converter_v2_1_20  -v2k5 "+incdir+/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/ec67/hdl" \
#"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/c4a6/hdl/axi_protocol_converter_v2_1_vl_rfs.v" \
#
#vlog -work core_ip_wraps  -v2k5 "+incdir+/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ipshared/ec67/hdl" \
#"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ip/core_ip_wraps_auto_pc_4/sim/core_ip_wraps_auto_pc_4.v" \
#"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ip/core_ip_wraps_auto_cc_7/sim/core_ip_wraps_auto_cc_7.v" \
#"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ip/core_ip_wraps_auto_cc_8/sim/core_ip_wraps_auto_cc_8.v" \
#"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ip/core_ip_wraps_auto_pc_5/sim/core_ip_wraps_auto_pc_5.v" \
#"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ip/core_ip_wraps_auto_cc_9/sim/core_ip_wraps_auto_cc_9.v" \
#"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ip/core_ip_wraps_auto_cc_10/sim/core_ip_wraps_auto_cc_10.v" \
#"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ip/core_ip_wraps_auto_cc_0/sim/core_ip_wraps_auto_cc_0.v" \
#"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ip/core_ip_wraps_auto_pc_0/sim/core_ip_wraps_auto_pc_0.v" \
#"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ip/core_ip_wraps_auto_cc_1/sim/core_ip_wraps_auto_cc_1.v" \
#"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ip/core_ip_wraps_auto_pc_1/sim/core_ip_wraps_auto_pc_1.v" \
#"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ip/core_ip_wraps_auto_cc_2/sim/core_ip_wraps_auto_cc_2.v" \
#"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ip/core_ip_wraps_auto_pc_2/sim/core_ip_wraps_auto_pc_2.v" \
#"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ip/core_ip_wraps_auto_cc_3/sim/core_ip_wraps_auto_cc_3.v" \
#"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ip/core_ip_wraps_auto_cc_4/sim/core_ip_wraps_auto_cc_4.v" \
#"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ip/core_ip_wraps_auto_pc_3/sim/core_ip_wraps_auto_pc_3.v" \
#"/home/riscv/core_ip_wraps/rtl/core_ip_wraps.srcs/sources_1/bd/core_ip_wraps/ip/core_ip_wraps_auto_cc_5/sim/core_ip_wraps_auto_cc_5.v" \
#
#vlog -work core_ip_wraps \
#"glbl.v" 
##2>&1 | tee -a compilexilinx.log
