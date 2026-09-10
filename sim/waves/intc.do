add wave /top/intc_if/intc_procss_clk
add wave /top/intc_if/intc_procss_rst

add wave -vgroup {INTC/AW_Channel} \
	/top/intc_if/intc_intr \
	/top/intc_if/intc_irq

wv.time.unit.auto.set
wv.zoom.fit
