add wave -vgroup {RTL/INTC} /top/dut/CORE_PERIF_CTRL/u_intc/*
add wave -vgroup {RTL/SPI}  /top/dut/CORE_PERIF_CTRL/u_spi/*
add wave -vgroup {RTL/GPIO} /top/dut/CORE_PERIF_CTRL/u_gpio/*
add wave -vgroup {RTL/UART} /top/dut/CORE_PERIF_CTRL/u_uart/*

wv.time.unit.auto.set
wv.zoom.fit
