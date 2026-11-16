wave "/top/lite_intc_if/ACLK"
wave "/top/lite_intc_if/ARESETn"

wave -vgroup {LITE_INTC/AW_Channel} \
	"/top/lite_intc_if/AWVALID" \
	"/top/lite_intc_if/AWREADY" \
	"/top/lite_intc_if/AWADDR"

wave -vgroup {LITE_INTC/W_Channel} \
	"/top/lite_intc_if/WVALID" \
	"/top/lite_intc_if/WREADY" \
	"/top/lite_intc_if/WDATA" \
	"/top/lite_intc_if/WSTRB"

wave -vgroup {LITE_INTC/B_Channel} \
	"/top/lite_intc_if/BVALID" \
	"/top/lite_intc_if/BREADY" \
	"/top/lite_intc_if/BRESP"

wave -vgroup {LITE_INTC/AR_Channel} \
	"/top/lite_intc_if/ARVALID" \
	"/top/lite_intc_if/ARREADY" \
	"/top/lite_intc_if/ARADDR"

wave -vgroup {LITE_INTC/R_Channel} \
	"/top/lite_intc_if/RRESP" \
	"/top/lite_intc_if/RREADY" \
	"/top/lite_intc_if/RVALID" \
	"/top/lite_intc_if/RDATA"

wv.time.unit.auto.set
wv.zoom.fit
