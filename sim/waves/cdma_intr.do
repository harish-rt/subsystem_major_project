add wave /top/cdma_interrupt_intf/aclk

add wave -expand -vgroup {CDMA_INTR/interrupt_out} \
	/top/cdma_interrupt_intf/interrupt_out

wv.time.unit.auto.set
wv.zoom.fit
