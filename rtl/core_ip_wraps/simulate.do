onbreak {quit -force}
onerror {quit -force}

vsim -t 1ps +access +r +m+core_ip_wraps -L xpm -L generic_baseblocks_v2_1_0 -L axi_infrastructure_v1_1_0 -L axi_register_slice_v2_1_20 -L fifo_generator_v13_2_5 -L axi_data_fifo_v2_1_19 -L axi_crossbar_v2_1_21 -L core_ip_wraps -L axi_lite_ipif_v3_0_4 -L axi_intc_v4_1_14 -L blk_mem_gen_v8_4_4 -L axi_bram_ctrl_v4_1_2 -L lib_pkg_v1_0_2 -L lib_srl_fifo_v1_0_2 -L lib_fifo_v1_0_14 -L lib_cdc_v1_0_2 -L axi_datamover_v5_1_22 -L axi_sg_v4_1_13 -L axi_cdma_v4_1_20 -L axi_clock_converter_v2_1_19 -L axi_protocol_converter_v2_1_20 -L unisims_ver -L unimacro_ver -L secureip -O5 core_ip_wraps.core_ip_wraps core_ip_wraps.glbl

run -all

endsim

quit -force
