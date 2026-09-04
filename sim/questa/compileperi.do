vlib lib
vlib lib/axi_intf
vlib lib/axi4_lite_mem
vlib lib/core_perif
vlib lib/spi_mem
vlib lib/core_wrapper

vmap axi_intf lib/axi_intf
vmap axi4_lite_mem lib/axi4_lite_mem
vmap core_perif lib/core_perif
vmap spi_mem lib/spi_mem
vmap core_wrapper lib/core_wrapper

vlog -work axi_intf "../../rtl/sub_ips/axi_intf/rtl/axi_intf.sv" \
"../../rtl/sub_ips/axi_intf/rtl/axi_lite_intf.sv"

vlog -work axi4_lite_mem "../../rtl/sub_ips/axi4_lite_memory_unit/rtl/axi4_lite_intf.sv" \
"../../rtl/sub_ips/axi4_lite_memory_unit/rtl/axi4_lite_memory_unit.sv"

vlog -work core_perif "../../rtl/sub_ips/core_perif/rtl/src_v/uart_lite_defs.v" \
"../../rtl/sub_ips/core_perif/rtl/src_v/uart_lite.v" \
"../../rtl/sub_ips/core_perif/rtl/src_v/timer_defs.v" \
"../../rtl/sub_ips/core_perif/rtl/src_v/timer.v" \
"../../rtl/sub_ips/core_perif/rtl/src_v/spi_lite_defs.v" \
"../../rtl/sub_ips/core_perif/rtl/src_v/spi_lite.v" \
"../../rtl/sub_ips/core_perif/rtl/src_v/gpio_defs.v" \
"../../rtl/sub_ips/core_perif/rtl/src_v/gpio.v" \
"../../rtl/sub_ips/core_perif/rtl/src_v/irq_ctrl_defs.v" \
"../../rtl/sub_ips/core_perif/rtl/src_v/irq_ctrl.v" \
"../../rtl/sub_ips/core_perif/rtl/src_v/axi4lite_dist.v" \
"../../rtl/sub_ips/core_perif/rtl/src_v/core_soc.v"

vlog -work core_wrapper \
     -L axi_intf \
     -L axi4_lite_mem \
     -L core_perif \
     -L spi_mem \
     -L core_ip_wraps \
     "../../rtl/core_wrapper.sv"



#vlib lib
#vlib lib/axi_intf
#vlib lib/axi4_lite_mem
#vlib lib/core_perif
#vlib lib/spi_mem
#vlib lib/core_wrapper
#
#vmap axi_intf lib/axi_intf
#vmap axi4_lite_mem lib/axi4_lite_mem
#vmap core_perif lib/core_perif
#vmap spi_mem lib/spi_mem
#vmap core_wrapper lib/core_wrapper
#
#vlog -work axi_intf "../../rtl/sub_ips/axi_intf/rtl/axi_intf.sv" \
#"../../rtl/sub_ips/axi_intf/rtl/axi_lite_intf.sv"
#
#vlog -work axi4_lite_mem "../../rtl/sub_ips/axi4_lite_memory_unit/rtl/axi4_lite_intf.sv" \
#"../../rtl/sub_ips/axi4_lite_memory_unit/rtl/axi4_lite_memory_unit.sv"
#
#vlog -work core_perif -v2k5 "../../rtl/sub_ips/core_perif/rtl/src_v/uart_lite_defs.v" \
#"../../rtl/sub_ips/core_perif/rtl/src_v/uart_lite.v" \
#"../../rtl/sub_ips/core_perif/rtl/src_v/timer_defs.v" \
#"../../rtl/sub_ips/core_perif/rtl/src_v/timer.v" \
#"../../rtl/sub_ips/core_perif/rtl/src_v/spi_lite_defs.v" \
#"../../rtl/sub_ips/core_perif/rtl/src_v/spi_lite.v" \
#"../../rtl/sub_ips/core_perif/rtl/src_v/gpio_defs.v" \
#"../../rtl/sub_ips/core_perif/rtl/src_v/gpio.v" \
#"../../rtl/sub_ips/core_perif/rtl/src_v/irq_ctrl_defs.v" \
#"../../rtl/sub_ips/core_perif/rtl/src_v/irq_ctrl.v" \
#"../../rtl/sub_ips/core_perif/rtl/src_v/axi4lite_dist.v" \
#"../../rtl/sub_ips/core_perif/rtl/src_v/core_soc.v"
#
#vlog -work core_wrapper -l axi_intf -l axi4_lite_mem -l core_perif -l spi_mem "../../rtl/core_wrapper.sv"

#vlog -work core_wrapper -l core_ip_wraps "../../rtl/core_wrapper.sv"









#vlib lib
#vlib lib/axi_intf
#vlib lib/axi4_lite_mem
#vlib lib/core_perif
#vlib lib/spi_mem
#vlib lib/core_wrapper
#
#vmap axi_intf lib/axi_intf
#vmap axi4_lite_mem lib/axi4_lite_mem
#vmap core_perif lib/core_perif
#vmap spi_mem lib/spi_mem
#vmap core_wrapper lib/core_wrapper
#
#vlog -work axi_intf "../../rtl/sub_ips/axi_intf/rtl/axi_intf.sv" \
#"../../rtl/sub_ips/axi_intf/rtl/axi_lite_intf.sv"
#
#vlog -work axi4_lite_mem "../../rtl/sub_ips/axi4_lite_memory_unit/rtl/axi4_lite_memory_unit.sv"
#
#vlog -work core_perif -v2k5 "../../rtl/sub_ips/core_perif/rtl/src_v/uart_lite_defs.v" \
#"../../rtl/sub_ips/core_perif/rtl/src_v/uart_lite.v" \
#"../../rtl/sub_ips/core_perif/rtl/src_v/timer_defs.v" \
#"../../rtl/sub_ips/core_perif/rtl/src_v/timer.v" \
#"../../rtl/sub_ips/core_perif/rtl/src_v/spi_lite_defs.v" \
#"../../rtl/sub_ips/core_perif/rtl/src_v/spi_lite.v" \
#"../../rtl/sub_ips/core_perif/rtl/src_v/gpio_defs.v" \
#"../../rtl/sub_ips/core_perif/rtl/src_v/gpio.v" \
#"../../rtl/sub_ips/core_perif/rtl/src_v/irq_ctrl_defs.v" \
#"../../rtl/sub_ips/core_perif/rtl/src_v/irq_ctrl.v" \
#"../../rtl/sub_ips/core_perif/rtl/src_v/axi4lite_dist.v" \
#"../../rtl/sub_ips/core_perif/rtl/src_v/core_soc.v"
#
#vlog -work spi_mem -v2k5 "+incdir+../../rtl/sub_ips/spi_mem/" \
#"../../rtl/sub_ips/spi_mem/ram.v" \
#"../../rtl/sub_ips/spi_mem/spi_logic.v" \
#"../../rtl/sub_ips/spi_mem/rtl.v"
#
#vlog -work core_wrapper \
#"../../rtl/sub_ips/axi_intf/rtl/axi_lite_intf.sv" \
#"../../rtl/sub_ips/core_perif/rtl/src_v/irq_ctrl_defs.v" \
#"../../rtl/sub_ips/core_perif/rtl/src_v/irq_ctrl.v" \
#"../../rtl/sub_ips/core_perif/rtl/src_v/axi4lite_dist.v" \
#"../../rtl/sub_ips/core_perif/rtl/src_v/uart_lite_defs.v" \
#"../../rtl/sub_ips/core_perif/rtl/src_v/uart_lite.v" \
#"../../rtl/sub_ips/core_perif/rtl/src_v/timer_defs.v" \
#"../../rtl/sub_ips/core_perif/rtl/src_v/timer.v" \
#"../../rtl/sub_ips/core_perif/rtl/src_v/spi_lite_defs.v" \
#"../../rtl/sub_ips/core_perif/rtl/src_v/spi_lite.v" \
#"../../rtl/sub_ips/core_perif/rtl/src_v/gpio_defs.v" \
#"../../rtl/sub_ips/core_perif/rtl/src_v/gpio.v" \
#"../../rtl/sub_ips/axi4_lite_memory_unit/rtl/axi4_lite_memory_unit.sv" \
#"../../rtl/sub_ips/core_perif/rtl/src_v/core_soc.v" \
#"../../rtl/sub_ips/core_wrapper.sv" 
##2>&1 | tee -a compileperi.log
