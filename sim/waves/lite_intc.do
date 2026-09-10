add wave /top/lite_intc_if/aclk
add wave /top/lite_intc_if/areset_n

add wave -vgroup {LITE_INTC/AW_Channel} \
	/top/lite_intc_if/axi_awvalid \
	/top/lite_intc_if/axi_awready \
	/top/lite_intc_if/axi_awaddr
add wave -vgroup {LITE_INTC/W_Channel} \
	/top/lite_intc_if/axi_wvalid \
	/top/lite_intc_if/axi_wready \
	/top/lite_intc_if/axi_wdata \
	/top/lite_intc_if/axi_wstrb
add wave -vgroup {LITE_INTC/B_Channel} \
	/top/lite_intc_if/axi_bvalid \
	/top/lite_intc_if/axi_bready \
	/top/lite_intc_if/axi_bresp
add wave -vgroup {LITE_INTC/AR_Channel} \
	/top/lite_intc_if/axi_arvalid \
	/top/lite_intc_if/axi_arready \
	/top/lite_intc_if/axi_araddr
add wave -vgroup {LITE_INTC/R_Channel} \
	/top/lite_intc_if/axi_rresp \
	/top/lite_intc_if/axi_rready \
	/top/lite_intc_if/axi_rvalid \
	/top/lite_intc_if/axi_rdata

wv.time.unit.auto.set
wv.zoom.fit
