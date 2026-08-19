vlib work
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

vlog -work axi_intf "../axi_intf/rtl/axi_intf.sv" \
"../axi_intf/rtl/axi_lite_intf.sv"

vlog -work axi4_lite_mem "../axi4_lite_memory_unit/rtl/axi4_lite_memory_unit.sv"

vlog -work core_perif -v2k5 "../core_perif/rtl/src_v/uart_lite_defs.v" \
"../core_perif/rtl/src_v/uart_lite.v" \
"../core_perif/rtl/src_v/timer_defs.v" \
"../core_perif/rtl/src_v/timer.v" \
"../core_perif/rtl/src_v/spi_lite_defs.v" \
"../core_perif/rtl/src_v/spi_lite.v" \
"../core_perif/rtl/src_v/gpio_defs.v" \
"../core_perif/rtl/src_v/gpio.v" \
"../core_perif/rtl/src_v/irq_ctrl_defs.v" \
"../core_perif/rtl/src_v/irq_ctrl.v" \
"../core_perif/rtl/src_v/axi4lite_dist.v" \
"../core_perif/rtl/src_v/core_soc.v"

vlog -work spi_mem -v2k5 "+incdir+../spi_mem/" \
"../spi_mem/ram.v" \
"../spi_mem/spi_logic.v" \
"../spi_mem/rtl.v"

vlog -work core_wrapper \
"../axi_intf/rtl/axi_lite_intf.sv" \
"../core_perif/rtl/src_v/irq_ctrl_defs.v" \
"../core_perif/rtl/src_v/irq_ctrl.v" \
"../core_perif/rtl/src_v/axi4lite_dist.v" \
"../core_perif/rtl/src_v/uart_lite_defs.v" \
"../core_perif/rtl/src_v/uart_lite.v" \
"../core_perif/rtl/src_v/timer_defs.v" \
"../core_perif/rtl/src_v/timer.v" \
"../core_perif/rtl/src_v/spi_lite_defs.v" \
"../core_perif/rtl/src_v/spi_lite.v" \
"../core_perif/rtl/src_v/gpio_defs.v" \
"../core_perif/rtl/src_v/gpio.v" \
"../axi4_lite_memory_unit/rtl/axi4_lite_memory_unit.sv" \
"../core_perif/rtl/src_v/core_soc.v" \
"../../core_wrapper.sv" \
2>&1 | tee -a compile.log
